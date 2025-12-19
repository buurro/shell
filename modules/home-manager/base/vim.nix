# NixVim Configuration - Converted from kickstart.nvim
# Import this module in your Home Manager configuration:
#
# { inputs, ... }:
# {
#   imports = [ inputs.nixvim.homeManagerModules.nixvim ./nixvim ];
#   programs.nixvim.enable = true;
# }

{ pkgs, lib, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # ============================================================================
    # GLOBAL VARIABLES
    # ============================================================================
    globals = {
      mapleader = " ";
      maplocalleader = " ";
      have_nerd_font = true;
    };

    # ============================================================================
    # OPTIONS
    # ============================================================================
    opts = {
      number = true;
      relativenumber = false;
      mouse = "a";
      clipboard = "unnamedplus";
      tabstop = 4;
      shiftwidth = 4;
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 10;
      updatetime = 250;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      list = true;
      listchars = {
        tab = "» ";
        lead = "·";
        trail = "·";
        nbsp = "␣";
      };
      inccommand = "split";
      completeopt = "menu,menuone,noselect";
      termguicolors = true;
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldenable = false;
    };

    # ============================================================================
    # DIAGNOSTICS
    # ============================================================================
    diagnostics = {
      severity_sort = true;
      float = { border = "rounded"; };
      underline = { severity = { min = "Error"; }; };
      virtual_text = {
        source = "if_many";
        prefix = "●";
      };
    };

    # ============================================================================
    # KEYMAPS
    # ============================================================================
    keymaps = [
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }
      { mode = "n"; key = "<C-h>"; action = "<C-w><C-h>"; options.desc = "Move focus left"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w><C-l>"; options.desc = "Move focus right"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w><C-j>"; options.desc = "Move focus down"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w><C-k>"; options.desc = "Move focus up"; }
      { mode = "n"; key = "<leader>q"; action = "<cmd>lua vim.diagnostic.setloclist()<CR>"; options.desc = "Quickfix list"; }
      { mode = "t"; key = "<Esc><Esc>"; action = "<C-\\\\><C-n>"; options.desc = "Exit terminal mode"; }
      { mode = "n"; key = "cd"; action = ":%s/\\\\<<C-r><C-w>\\\\>/<C-r><C-w>/gI<Left><Left><Left>"; options.desc = "Find and replace word"; }
      { mode = "n"; key = "<leader>f"; action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<CR>"; options.desc = "Format buffer"; }
      { mode = "n"; key = "\\\\"; action = "<cmd>Neotree toggle<CR>"; options.desc = "Toggle Neo-tree"; }

      # Trouble
      { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle<CR>"; options.desc = "Diagnostics (Trouble)"; }
      { mode = "n"; key = "<leader>xX"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>"; options.desc = "Buffer Diagnostics"; }
      { mode = "n"; key = "<leader>cs"; action = "<cmd>Trouble symbols toggle focus=false<CR>"; options.desc = "Symbols"; }
      { mode = "n"; key = "<leader>cl"; action = "<cmd>Trouble lsp toggle focus=false win.position=right<CR>"; options.desc = "LSP refs"; }
      { mode = "n"; key = "<leader>xL"; action = "<cmd>Trouble loclist toggle<CR>"; options.desc = "Location List"; }
      { mode = "n"; key = "<leader>xQ"; action = "<cmd>Trouble qflist toggle<CR>"; options.desc = "Quickfix List"; }
    ];

    # ============================================================================
    # AUTOCOMMANDS
    # ============================================================================
    autoGroups = {
      kickstart-highlight-yank = { clear = true; };
      lint = { clear = true; };
    };

    autoCmd = [
      {
        event = "TextYankPost";
        group = "kickstart-highlight-yank";
        desc = "Highlight when yanking text";
        callback.__raw = "function() vim.highlight.on_yank() end";
      }
      {
        event = [ "BufEnter" "BufWritePost" "InsertLeave" ];
        group = "lint";
        callback.__raw = ''
          function()
            if vim.opt_local.modifiable:get() then
              require("lint").try_lint()
            end
          end
        '';
      }
    ];

    # ============================================================================
    # LSP (using NixVim's LSP module - this one usually works)
    # ============================================================================
    plugins.lsp = {
      enable = true;
      inlayHints = true;
      keymaps = {
        lspBuf = {
          "grn" = { action = "rename"; desc = "Rename"; };
          "gra" = { action = "code_action"; desc = "Code Action"; };
          "grr" = { action = "references"; desc = "References"; };
          "gri" = { action = "implementation"; desc = "Implementation"; };
          "grd" = { action = "definition"; desc = "Definition"; };
          "grD" = { action = "declaration"; desc = "Declaration"; };
          "grt" = { action = "type_definition"; desc = "Type Definition"; };
          "gO" = { action = "document_symbol"; desc = "Document Symbols"; };
          "gW" = { action = "workspace_symbol"; desc = "Workspace Symbols"; };
        };
      };
      servers = {
        lua_ls = {
          enable = true;
          settings.Lua = {
            completion.callSnippet = "Replace";
            diagnostics.globals = [ "vim" ];
          };
        };
        pyright.enable = true;
        ruff.enable = true;
        ts_ls.enable = true;
        gopls.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        clangd.enable = true;
        nil_ls.enable = true;
        html.enable = true;
        cssls.enable = true;
        jsonls.enable = true;
        bashls.enable = true;
      };
    };

    # Treesitter - handled via extraPlugins

    # ============================================================================
    # EXTRA PLUGINS (packages only - setup in extraConfigLua)
    # ============================================================================
    extraPlugins = with pkgs.vimPlugins; [
      # Colorscheme
      tokyonight-nvim

      # Treesitter with parsers
      (nvim-treesitter.withPlugins (p: [
        p.bash p.c p.diff p.html p.lua p.luadoc p.markdown p.markdown_inline
        p.query p.vim p.vimdoc p.python p.javascript p.typescript p.tsx
        p.json p.yaml p.toml p.nix p.go p.rust
      ]))

      # UI
      nvim-web-devicons
      which-key-nvim
      indent-blankline-nvim
      todo-comments-nvim
      trouble-nvim
      neo-tree-nvim
      dropbar-nvim
      fidget-nvim

      # Editing
      vim-sleuth
      comment-nvim
      nvim-autopairs
      mini-nvim

      # Telescope
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      plenary-nvim

      # Completion
      blink-cmp
      luasnip
      friendly-snippets

      # Formatting & Linting
      conform-nvim
      nvim-lint

      # Git
      gitsigns-nvim

      # Navigation
      harpoon2

      # Debug
      nvim-dap
      nvim-dap-ui
      nvim-dap-go
      nvim-dap-python
      nvim-nio

      # Misc
      lazydev-nvim
      neotest
      neotest-phpunit
    ];

    # ============================================================================
    # EXTRA PACKAGES (formatters, linters, etc.)
    # ============================================================================
    extraPackages = with pkgs; [
      # Formatters
      stylua
      nixpkgs-fmt
      nodePackages.prettier
      ruff
      gofumpt

      # Linters
      luajitPackages.luacheck
      statix
      eslint_d
      golangci-lint

      # Tools
      ripgrep
      fd
    ];

    # ============================================================================
    # EXTRA CONFIG LUA (all plugin setup)
    # ============================================================================
    extraConfigLua = ''
      -- Tokyonight
      require("tokyonight").setup({
        style = "night",
        styles = { comments = { italic = false } },
      })
      vim.cmd.colorscheme("tokyonight-night")

      -- Web devicons
      require("nvim-web-devicons").setup({})

      -- Treesitter
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent = { enable = true, disable = { "ruby" } },
      })

      -- Which-key
      require("which-key").setup({
        preset = "modern",
        spec = {
          { "<leader>s", group = "[S]earch" },
          { "<leader>t", group = "[T]oggle" },
          { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
          { "<leader>x", group = "Trouble" },
          { "<leader>c", group = "[C]ode" },
        },
      })

      -- Telescope
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "^.git/", "node_modules" },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("ui-select")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files" })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "Fuzzily search in buffer" })
      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
      end, { desc = "[S]earch in Open Files" })
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })

      -- Fidget
      require("fidget").setup({ notification = { window = { winblend = 0 } } })

      -- Lazydev
      require("lazydev").setup({
        library = {
          { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      })

      -- Blink completion
      require("blink.cmp").setup({
        keymap = { preset = "enter" },
        appearance = { nerd_font_variant = "mono" },
        signature = { enabled = true },
        completion = {
          documentation = { auto_show = false, auto_show_delay_ms = 500 },
          menu = { auto_show = true },
        },
        sources = {
          default = { "lsp", "path", "snippets", "lazydev" },
          providers = {
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 100,
            },
          },
        },
      })

      -- Luasnip
      require("luasnip").setup({ history = true, delete_check_events = "TextChanged" })

      -- Autopairs
      require("nvim-autopairs").setup({})

      -- Conform (formatting)
      require("conform").setup({
        notify_on_error = false,
        format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
        formatters_by_ft = {
          lua = { "stylua" },
          nix = { "nixpkgs-fmt" },
          python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          php = { "prettier" },
          go = { "gofmt" },
          rust = { "rustfmt" },
        },
      })

      -- Lint
      require("lint").linters_by_ft = {
        python = { "ruff" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        lua = { "luacheck" },
        nix = { "statix" },
        go = { "golangcilint" },
      }

      -- Gitsigns
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map("n", "]c", function()
            if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
          end, { desc = "Next git change" })
          map("n", "[c", function()
            if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
          end, { desc = "Prev git change" })
          map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage hunk" })
          map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset hunk" })
          map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
          map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
          map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
          map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
          map("n", "<leader>hb", gs.blame_line, { desc = "Blame line" })
          map("n", "<leader>hd", gs.diffthis, { desc = "Diff index" })
          map("n", "<leader>hD", function() gs.diffthis("@") end, { desc = "Diff last commit" })
          map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle blame" })
          map("n", "<leader>tD", gs.toggle_deleted, { desc = "Toggle deleted" })
        end,
      })

      -- Todo comments
      require("todo-comments").setup({ signs = true })

      -- Indent blankline
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true },
      })

      -- Mini
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup({})
      require("mini.statusline").setup({ use_icons = vim.g.have_nerd_font })

      -- Neo-tree
      require("neo-tree").setup({
        close_if_last_window = true,
        window = { position = "right", width = 40 },
        filesystem = {
          follow_current_file = { enabled = true },
          filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false },
        },
      })

      -- Trouble
      require("trouble").setup({})

      -- Dropbar
      require("dropbar").setup({})
      vim.keymap.set("n", "<Leader>;", function() require("dropbar.api").pick() end, { desc = "Pick symbols" })
      vim.keymap.set("n", "[;", function() require("dropbar.api").goto_context_start() end, { desc = "Context start" })
      vim.keymap.set("n", "];", function() require("dropbar.api").select_next_context() end, { desc = "Next context" })

      -- Harpoon
      local harpoon = require("harpoon")
      harpoon:setup({})
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add" })
      vim.keymap.set("n", "<leader>e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon 1" })
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon 2" })
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon 3" })
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon 4" })
      vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "Harpoon prev" })
      vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = "Harpoon next" })

      -- DAP
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      })
      require("dap-go").setup({})
      require("dap-python").setup("python")

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Conditional Breakpoint" })
      vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Toggle DAP UI" })

      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#993939" })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bg = "#31353f" })

      -- Diagnostic signs
      local signs = { Error = "", Warn = "", Hint = "", Info = "" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- Toggle inlay hints
      if vim.lsp.inlay_hint then
        vim.keymap.set("n", "<leader>th", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
        end, { desc = "Toggle Inlay Hints" })
      end
    '';
  };
}
