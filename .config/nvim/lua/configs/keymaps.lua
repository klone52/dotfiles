-- For conciseness
local opts = { noremap = true, silent = true }

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- save file
vim.keymap.set("n", "<leader>ww", "<cmd> w <CR>", { desc = "Save file", noremap = true, silent = true })
vim.keymap.set("n", "<leader>wa", "<cmd> wa <CR>", { desc = "Save all files", noremap = true, silent = true })
vim.keymap.set(
	"n",
	"<leader>wn",
	"<cmd> noautocmd w <CR>",
	{ desc = "Save file without auto-formatting", noremap = true, silent = true }
)

-- quit file
vim.keymap.set("n", "<leader>qq", "<cmd> q <CR>", { desc = "Quit file", noremap = true, silent = true })
vim.keymap.set("n", "<leader>qa", "<cmd> qa <CR>", { desc = "Quit All files", noremap = true, silent = true })
vim.keymap.set("n", "<leader>Q", "<cmd> qa! <CR>", { desc = "Quit All files force", noremap = true, silent = true })

-- save and quit
vim.keymap.set("n", "<leader>wq", "<cmd> wq <CR>", { desc = "Save and Quit file", noremap = true, silent = true })
vim.keymap.set("n", "<leader>wqa", "<cmd> wqa <CR>", { desc = "Save and Quit al files", noremap = true, silent = true })
-- delete single character without copying into register
vim.keymap.set("n", "x", '"_x', opts)

-- Vertical scroll and center
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Find and center
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

-- Buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", opts)

-- Increment/decrement numbers
--  test: 10
vim.keymap.set("n", "<leader>+", "<C-a>", opts) -- increment
vim.keymap.set("n", "<leader>-", "<C-x>", opts) -- decrement

vim.keymap.set("n", "J", "mzJ`z")

-- Window management
vim.keymap.set("n", "<leader>v", "<C-w>v", opts) -- split window vertically
vim.keymap.set("n", "<leader>h", "<C-w>s", opts) -- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", opts) -- make split windows equal width & height
vim.keymap.set("n", "<leader>xs", ":close<CR>", opts) -- close current split window

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window", noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window", noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window", noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window", noremap = true, silent = true })

-- -- Navigate between splits
-- vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', opts)
-- vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', opts)
-- vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', opts)
-- vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', opts)

-- Tabs
vim.keymap.set("n", "<leader>to", ":tabnew<CR>", opts) -- open new tab
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", opts) -- close current tab
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", opts) --  go to next tab
vim.keymap.set("n", "<leader>tp", ":tabp<CR>", opts) --  go to previous tab

-- Toggle line wrapping
vim.keymap.set("n", "<leader>lw", "<cmd>set wrap!<CR>", opts)

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Keep last yanked when pasting
vim.keymap.set("v", "p", '"_dP', opts)

-- Rename variable
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Make current file into an executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
