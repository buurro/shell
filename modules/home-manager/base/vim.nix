{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      have_nerd_font = true;
    };

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

    diagnostics = {
      severity_sort = true;
      float.border = "rounded";
      underline.severity.min = "Error";
      virtual_text = {
        source = "if_many";
        prefix = "●";
      };
    };

    colorschemes.tokyonight = {
      enable = true;
      settings = {
        style = "night";
        styles.comments.italic = false;
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w><C-h>";
        options.desc = "Move focus left";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w><C-l>";
        options.desc = "Move focus right";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w><C-j>";
        options.desc = "Move focus down";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w><C-k>";
        options.desc = "Move focus up";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
        options.desc = "Quickfix list";
      }
      {
        mode = "t";
        key = "<Esc><Esc>";
        action = "<C-\\\\><C-n>";
        options.desc = "Exit terminal mode";
      }
      {
        mode = "n";
        key = "cd";
        action = ":%s/\\\\<<C-r><C-w>\\\\>/<C-r><C-w>/gI<Left><Left><Left>";
        options.desc = "Find and replace word";
      }
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<CR>";
        options.desc = "Format buffer";
      }
      {
        mode = "n";
        key = "\\\\";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle Neo-tree";
      }

      # Trouble
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<CR>";
        options.desc = "Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>xX";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
        options.desc = "Buffer Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>cs";
        action = "<cmd>Trouble symbols toggle focus=false<CR>";
        options.desc = "Symbols";
      }
      {
        mode = "n";
        key = "<leader>cl";
        action = "<cmd>Trouble lsp toggle focus=false win.position=right<CR>";
        options.desc = "LSP refs";
      }
      {
        mode = "n";
        key = "<leader>xL";
        action = "<cmd>Trouble loclist toggle<CR>";
        options.desc = "Location List";
      }
      {
        mode = "n";
        key = "<leader>xQ";
        action = "<cmd>Trouble qflist toggle<CR>";
        options.desc = "Quickfix List";
      }

      # Harpoon
      {
        mode = "n";
        key = "<leader>a";
        action.__raw = "function() require('harpoon'):list():add() end";
        options.desc = "Harpoon add";
      }
      {
        mode = "n";
        key = "<leader>e";
        action.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end";
        options.desc = "Harpoon menu";
      }
      {
        mode = "n";
        key = "<leader>1";
        action.__raw = "function() require('harpoon'):list():select(1) end";
        options.desc = "Harpoon 1";
      }
      {
        mode = "n";
        key = "<leader>2";
        action.__raw = "function() require('harpoon'):list():select(2) end";
        options.desc = "Harpoon 2";
      }
      {
        mode = "n";
        key = "<leader>3";
        action.__raw = "function() require('harpoon'):list():select(3) end";
        options.desc = "Harpoon 3";
      }
      {
        mode = "n";
        key = "<leader>4";
        action.__raw = "function() require('harpoon'):list():select(4) end";
        options.desc = "Harpoon 4";
      }
      {
        mode = "n";
        key = "<C-S-P>";
        action.__raw = "function() require('harpoon'):list():prev() end";
        options.desc = "Harpoon prev";
      }
      {
        mode = "n";
        key = "<C-S-N>";
        action.__raw = "function() require('harpoon'):list():next() end";
        options.desc = "Harpoon next";
      }

      # Dropbar
      {
        mode = "n";
        key = "<Leader>;";
        action.__raw = "function() require('dropbar.api').pick() end";
        options.desc = "Pick symbols";
      }
      {
        mode = "n";
        key = "[;";
        action.__raw = "function() require('dropbar.api').goto_context_start() end";
        options.desc = "Context start";
      }
      {
        mode = "n";
        key = "];";
        action.__raw = "function() require('dropbar.api').select_next_context() end";
        options.desc = "Next context";
      }
    ];

    autoGroups = {
      kickstart-highlight-yank.clear = true;
      lint.clear = true;
    };

    autoCmd = [
      {
        event = "TextYankPost";
        group = "kickstart-highlight-yank";
        desc = "Highlight when yanking text";
        callback.__raw = "function() vim.highlight.on_yank() end";
      }
      {
        event = [
          "BufEnter"
          "BufWritePost"
          "InsertLeave"
        ];
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

    plugins = {
      web-devicons.enable = true;
      sleuth.enable = true;
      comment.enable = true;
      nvim-autopairs.enable = true;

      which-key = {
        enable = true;
        settings = {
          preset = "modern";
          spec = [
            {
              __unkeyed-1 = "<leader>s";
              group = "[S]earch";
            }
            {
              __unkeyed-1 = "<leader>t";
              group = "[T]oggle";
            }
            {
              __unkeyed-1 = "<leader>h";
              group = "Git [H]unk";
              mode = [
                "n"
                "v"
              ];
            }
            {
              __unkeyed-1 = "<leader>x";
              group = "Trouble";
            }
            {
              __unkeyed-1 = "<leader>c";
              group = "[C]ode";
            }
          ];
        };
      };

      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
          ui-select.enable = true;
        };
        settings = {
          defaults.file_ignore_patterns = [
            "^.git/"
            "node_modules"
          ];
          pickers.find_files.hidden = true;
        };
        keymaps = {
          "<leader>sh" = {
            action = "help_tags";
            options.desc = "[S]earch [H]elp";
          };
          "<leader>sk" = {
            action = "keymaps";
            options.desc = "[S]earch [K]eymaps";
          };
          "<leader>sf" = {
            action = "find_files";
            options.desc = "[S]earch [F]iles";
          };
          "<leader>ss" = {
            action = "builtin";
            options.desc = "[S]earch [S]elect Telescope";
          };
          "<leader>sw" = {
            action = "grep_string";
            options.desc = "[S]earch current [W]ord";
          };
          "<leader>sg" = {
            action = "live_grep";
            options.desc = "[S]earch by [G]rep";
          };
          "<leader>sd" = {
            action = "diagnostics";
            options.desc = "[S]earch [D]iagnostics";
          };
          "<leader>sr" = {
            action = "resume";
            options.desc = "[S]earch [R]esume";
          };
          "<leader>s." = {
            action = "oldfiles";
            options.desc = "[S]earch Recent Files";
          };
          "<leader><leader>" = {
            action = "buffers";
            options.desc = "Find buffers";
          };
        };
      };

      lsp = {
        enable = true;
        inlayHints = true;
        keymaps = {
          lspBuf = {
            "grn" = {
              action = "rename";
              desc = "Rename";
            };
            "gra" = {
              action = "code_action";
              desc = "Code Action";
            };
            "grr" = {
              action = "references";
              desc = "References";
            };
            "gri" = {
              action = "implementation";
              desc = "Implementation";
            };
            "grd" = {
              action = "definition";
              desc = "Definition";
            };
            "grD" = {
              action = "declaration";
              desc = "Declaration";
            };
            "grt" = {
              action = "type_definition";
              desc = "Type Definition";
            };
            "gO" = {
              action = "document_symbol";
              desc = "Document Symbols";
            };
            "gW" = {
              action = "workspace_symbol";
              desc = "Workspace Symbols";
            };
          };
        };
        servers = {
          lua_ls = {
            enable = true;
            settings.Lua = {
              completion.callSnippet = "Replace";
              diagnostics.globals = ["vim"];
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

      # Fidget - LSP progress
      fidget = {
        enable = true;
        settings.notification.window.winblend = 0;
      };

      # LazyDev - Lua development
      lazydev = {
        enable = true;
        settings.library = [
          {
            path = "luvit-meta/library";
            words = ["vim%.uv"];
          }
        ];
      };

      # ------------------------------------------------------------------------
      # Completion
      # ------------------------------------------------------------------------
      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "enter";
          appearance.nerd_font_variant = "mono";
          signature.enabled = true;
          completion = {
            documentation = {
              auto_show = false;
              auto_show_delay_ms = 500;
            };
            menu.auto_show = true;
          };
          sources = {
            default = [
              "lsp"
              "path"
              "snippets"
              "lazydev"
            ];
            providers.lazydev = {
              name = "LazyDev";
              module = "lazydev.integrations.blink";
              score_offset = 100;
            };
          };
        };
      };

      luasnip = {
        enable = true;
        settings = {
          history = true;
          delete_check_events = "TextChanged";
        };
      };

      friendly-snippets.enable = true;

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent = {
            enable = true;
            disable = ["ruby"];
          };
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          c
          diff
          html
          lua
          luadoc
          markdown
          markdown_inline
          query
          vim
          vimdoc
          python
          javascript
          typescript
          tsx
          json
          yaml
          toml
          nix
          go
          rust
        ];
      };

      # ------------------------------------------------------------------------
      # Formatting
      # ------------------------------------------------------------------------
      conform-nvim = {
        enable = true;
        settings = {
          notify_on_error = false;
          format_on_save = {
            timeout_ms = 500;
            lsp_format = "fallback";
          };
          formatters_by_ft = {
            lua = ["stylua"];
            nix = ["alejandra"];
            python = ["ruff_fix" "ruff_format" "ruff_organize_imports"];
            javascript = ["prettier"];
            typescript = ["prettier"];
            javascriptreact = ["prettier"];
            typescriptreact = ["prettier"];
            json = ["prettier"];
            yaml = ["prettier"];
            markdown = ["prettier"];
            html = ["prettier"];
            css = ["prettier"];
            php = ["prettier"];
            go = ["gofmt"];
            rust = ["rustfmt"];
          };
        };
      };

      lint = {
        enable = true;
        lintersByFt = {
          python = ["ruff"];
          javascript = ["eslint_d"];
          typescript = ["eslint_d"];
          lua = ["luacheck"];
          nix = ["statix"];
          go = ["golangcilint"];
        };
      };

      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "+";
            change.text = "~";
            delete.text = "_";
            topdelete.text = "‾";
            changedelete.text = "~";
          };
          on_attach.__raw = ''
            function(bufnr)
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
            end
          '';
        };
      };

      todo-comments = {
        enable = true;
        settings.signs = true;
      };

      indent-blankline = {
        enable = true;
        settings = {
          indent.char = "│";
          scope.enabled = true;
        };
      };

      mini = {
        enable = true;
        modules = {
          ai.n_lines = 500;
          surround = {};
          statusline.use_icons.__raw = "vim.g.have_nerd_font";
        };
      };

      # ------------------------------------------------------------------------
      # File explorer
      # ------------------------------------------------------------------------
      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          window = {
            position = "right";
            width = 40;
          };
          filesystem = {
            follow_current_file.enabled = true;
            filtered_items = {
              visible = true;
              hide_dotfiles = false;
              hide_gitignored = false;
            };
          };
        };
      };

      trouble = {
        enable = true;
        settings = {};
      };

      dropbar.enable = true;

      harpoon = {
        enable = true;
        enableTelescope = true;
      };

      dap = {
        enable = true;
        signs = {
          dapBreakpoint = {
            text = "";
            texthl = "DapBreakpoint";
          };
          dapBreakpointCondition = {
            text = "";
            texthl = "DapBreakpointCondition";
          };
          dapStopped = {
            text = "";
            texthl = "DapStopped";
            linehl = "DapStopped";
          };
        };
      };

      dap-ui = {
        enable = true;
        settings.icons = {
          expanded = "▾";
          collapsed = "▸";
          current_frame = "*";
        };
      };

      dap-go.enable = true;
      dap-python.enable = true;

      # ------------------------------------------------------------------------
      # Neotest
      # ------------------------------------------------------------------------
      neotest = {
        enable = true;
        adapters.phpunit.enable = true;
      };
    };

    # ==========================================================================
    # EXTRA PACKAGES
    # ==========================================================================
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

    # ==========================================================================
    # EXTRA CONFIG (things that can't be expressed in Nix)
    # ==========================================================================
    extraConfigLua = ''
      -- Additional Telescope keymaps
      local builtin = require("telescope.builtin")
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

      -- DAP keymaps
      local dap = require("dap")
      local dapui = require("dapui")
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

      -- DAP highlight groups
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
