vim.cmd("let g:netre_liststyle = 3")

local opt = vim.opt

-- numbers
opt.relativenumber = true
opt.number = true

-- tabs &  indentation
opt.tabstop = 2      -- tabs
opt.shiftwidth = 2   -- indent width
opt.expandtab = true -- expand tab to spaces

-- search
opt.ignorecase = true
opt.smartcase = true -- case sensitive with mixed case in search

-- clipboard
opt.clipboard:append("unnamedplus") --use system clipboard
