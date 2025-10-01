return {
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup()
    end
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()

      vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
    end
  }
}
