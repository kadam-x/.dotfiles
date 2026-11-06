return {
  'romgrk/barbar.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  opts = {
    animation = false,
    auto_hide = false,
    icons = {
      button = false,
      -- separator = { left = '', right = '' },
      separator_at_end = false,
    },
  },
  config = function(_, opts)
    require('barbar').setup(opts)

    local map = vim.keymap.set
    local map_opts = { noremap = true, silent = true }

    map('n', '<Tab>', '<Cmd>BufferNext<CR>', map_opts)
    map('n', '<S-Tab>', '<Cmd>BufferPrevious<CR>', map_opts)

    -- Make the tabline background transparent
    local function clear_barbar_bg()
      for name, _ in pairs(vim.api.nvim_get_hl(0, {})) do
        if name:match('^Buffer') then
          local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
          hl.bg = 'NONE'
          hl.ctermbg = 'NONE'
          vim.api.nvim_set_hl(0, name, hl)
        end
      end
    end

    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('BarbarTransparent', { clear = true }),
      callback = function()
        -- schedule so it runs after barbar re-derives its own highlights
        vim.schedule(clear_barbar_bg)
      end,
    })

    clear_barbar_bg()
  end,
}
