vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  { src = "https://github.com/j-hui/fidget.nvim" },
  { src = "https://github.com/b0o/SchemaStore.nvim" },
})

require("mason").setup({})
require("fidget").setup({})

vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN]  = "󰀪 ",
      [vim.diagnostic.severity.INFO]  = "󰋽 ",
      [vim.diagnostic.severity.HINT]  = "󰌶 ",
    },
  },
  virtual_text = false,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("mattallan-lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    local tb = require("telescope.builtin")

    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("gra", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })
    map("grr", tb.lsp_references, "[G]oto [R]eferences")
    map("gri", tb.lsp_implementations, "[G]oto [I]mplementation")
    map("grd", tb.lsp_definitions, "[G]oto [D]efinition")
    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    -- Muscle-memory aliases. Without these, `gd` falls back to Vim's built-in
    -- "local declaration" search, which never leaves the current file.
    map("gd", tb.lsp_definitions, "[G]oto [D]efinition")
    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    map("gI", tb.lsp_implementations, "[G]oto [I]mplementation")
    map("gy", tb.lsp_type_definitions, "[G]oto T[y]pe Definition")
    map("grt", tb.lsp_type_definitions, "[G]oto [T]ype Definition")
    map("gO", tb.lsp_document_symbols, "Document Symbols")
    map("gW", tb.lsp_dynamic_workspace_symbols, "Workspace Symbols")
    map("K", vim.lsp.buf.hover, "Hover Documentation")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local group = vim.api.nvim_create_augroup("mattallan-lsp-highlight", { clear = false })

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("mattallan-lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "mattallan-lsp-highlight", buffer = event2.buf })
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "[T]oggle Inlay [H]ints")
    end
  end,
})

local vue_language_server_path =
  vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = vue_language_server_path,
  languages = { "vue" },
  configNamespace = "typescript",
}

local ts_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "vue",
}

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library",
        },
      },
      completion = {
        callSnippet = "Replace",
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.config("intelephense", {
  filetypes = { "php", "blade" },
  settings = {
    intelephense = {
      environment = {
        phpVersion = "8.4",
      },
      files = {
        maxSize = 5000000,
        -- Replaces intelephense's default exclude list, so the defaults are
        -- repeated here. Extra entries (.claude, storage) stop it indexing
        -- stray nested git worktrees and Laravel runtime junk — without these
        -- it tries to index ~145k duplicate PHP files and freezes on open.
        exclude = {
          "**/.git/**",
          "**/.svn/**",
          "**/.hg/**",
          "**/CVS/**",
          "**/.DS_Store/**",
          "**/node_modules/**",
          "**/bower_components/**",
          "**/vendor/**/{Tests,tests}/**",
          "**/.history/**",
          "**/vendor/**/vendor/**",
          "**/.claude/**",
          "**/storage/framework/**",
          "**/storage/logs/**",
        },
      },
    },
  },
  init_options = {
    licenceKey = vim.env.INTELEPHENSE_LICENCE_KEY,
  },
})

-- Locates the Tailwind v4 entry stylesheet (the one with `@import "tailwindcss"`).
--
-- nvim-lspconfig does this in its own tailwindcss `before_init` via an unbounded,
-- synchronous `vim.fs.find` over the entire git root, with no exclusions. In
-- tc-portal (~380k files) that walk blocks the UI for ~15s on the first buffer
-- opened. rg does the same lookup in ~60ms, so do it ourselves — upstream's
-- `before_init` is replaced by ours below, since vim.lsp.config merges with
-- `tbl_deep_extend('force', ...)` and function values overwrite.
local function tailwind_entry_css(root)
  if not root or vim.fn.executable("rg") == 0 then
    return nil
  end

  local result = vim.system({
    "rg", "--files-with-matches", "--max-count", "1",
    "--glob", "*.css", "--glob", "*.scss", "--glob", "*.pcss",
    [[@import ['"]tailwindcss]],
    root,
  }, { text = true }):wait(5000)

  local first = vim.split(result.stdout or "", "\n", { trimempty = true })[1]
  return first ~= "" and first or nil
end

vim.lsp.config("tailwindcss", {
  -- Replaces lspconfig's before_init. Mirrors its editor.tabSize setup, but
  -- resolves experimental.configFile with the fast lookup above.
  before_init = function(_, config)
    config.settings = config.settings or {}
    config.settings.editor = config.settings.editor or {}
    config.settings.editor.tabSize = config.settings.editor.tabSize
      or vim.lsp.util.get_effective_tabstop()

    local tw = config.settings.tailwindCSS or {}
    tw.experimental = tw.experimental or {}
    tw.experimental.configFile = tw.experimental.configFile or tailwind_entry_css(config.root_dir)
    config.settings.tailwindCSS = tw
  end,
  filetypes = {
    "html", "css", "scss", "sass", "less",
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "vue", "svelte", "astro",
    "blade", "php",
  },
  settings = {
    tailwindCSS = {
      classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
      includeLanguages = {
        blade = "html",
        php = "html",
      },
      -- Replaces the server's default exclude list; keep its defaults and add
      -- .claude (stray nested worktrees), vendor and storage so it doesn't
      -- crawl the whole tree looking for class sources.
      files = {
        exclude = {
          "**/.git/**",
          "**/node_modules/**",
          "**/.hg/**",
          "**/.svn/**",
          "**/.claude/**",
          "**/vendor/**",
          "**/storage/**",
        },
      },
    },
  },
})

vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

vim.lsp.config("bashls", {})

vim.lsp.config("vtsls", {
  filetypes = ts_filetypes,
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
})

vim.lsp.config("vue_ls", {})

require("mason-tool-installer").setup({
  ensure_installed = {
    "stylua",
    "prettier",
    "pint",
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "intelephense",
    "vtsls",
    "vue_ls",
    "tailwindcss",
    "jsonls",
    "bashls",
  },
  automatic_enable = true,
})
