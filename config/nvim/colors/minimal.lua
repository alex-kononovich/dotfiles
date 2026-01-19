local black = "#262626"
local white = "#D6D6D6"
local red = "#F58E8E"
local green = "#A8D2AA"
local yellow = "#FCD27E"
local blue = "#7AAAD3"
local magenta = "#D6ADD5"
local cyan = "#79D4D5"
local darkgrey = "#646464"
local lightgrey = "#979797"
local selectionBg = "#3B3B3B"
local statuslineBg = "#4A4A4A"

local colors = {
  Normal = { fg = white, bg = black },
  Boolean = { link = "Normal" },
  Changed = { link = "Normal" },
  Constant = { link = "Normal" },
  Directory = { link = "Normal" },
  Float = { link = "Normal" },
  Function = { link = "Normal" },
  Identifier = { link = "Normal" },
  MoreMsg = { link = "Normal" },
  NormalFloat = { link = "Normal" },
  Number = { link = "Normal" },
  TabLineSel = { link = "Normal" },
  Type = { link = "Normal" },
  Added = { fg = green },
  DiffAdd = { link = "Added" },
  DiffChange = { link = "Changed" },
  Character = { fg = cyan },
  Comment = { fg = lightgrey },
  CurSearch = { underline = true },
  Search = { link = "CurSearch" },
  Delimiter = { fg = yellow },
  diffLine = { link = "Delimiter" },
  DevIconBrewfile = { fg = red },
  DevIconConfigRu = { fg = red },
  DevIconErb = { fg = red },
  DevIconGemfile = { fg = red },
  DevIconGemspec = { fg = red },
  DevIconRake = { fg = red },
  DevIconRakefile = { fg = red },
  DevIconRb = { fg = red },
  DiagnosticHint = { fg = blue },
  DiagnosticInfo = { fg = cyan },
  DiagnosticOk = { fg = green },
  DiagnosticUnderlineError = { sp = red, undercurl = true },
  DiagnosticUnderlineHint = { sp = blue, undercurl = true },
  DiagnosticUnderlineInfo = { sp = cyan, undercurl = true },
  DiagnosticUnderlineOk = { sp = green, undercurl = true },
  DiagnosticUnderlineWarn = { sp = yellow, undercurl = true },
  DiffText = { bg = darkgrey },
  Error = { fg = black, bg = red },
  ErrorMsg = { fg = red },
  DiagnosticError = { link = "ErrorMsg" },
  Folded = { fg = darkgrey },
  MatchParen = { fg = yellow, bg = selectionBg, bold = true },
  ModeMsg = { fg = green },
  NonText = { fg = darkgrey },
  Conceal = { link = "NonText" },
  DiagnosticVirtualTextError = { link = "NonText" },
  DiagnosticVirtualTextHint = { link = "NonText" },
  DiagnosticVirtualTextInfo = { link = "NonText" },
  DiagnosticVirtualTextOk = { link = "NonText" },
  DiagnosticVirtualTextWarn = { link = "NonText" },
  Ignore = { link = "NonText" },
  LineNr = { link = "NonText" },
  SignColumn = { link = "NonText" },
  SpecialKey = { link = "NonText" },
  Pmenu = { fg = white, bg = darkgrey },
  PmenuSbar = { link = "Pmenu" },
  PmenuThumb = { link = "Pmenu" },
  PmenuExtra = { fg = lightgrey, bg = darkgrey },
  PmenuKind = { link = "PmenuExtra" },
  PmenuExtraSel = { fg = lightgrey, bg = yellow },
  PmenuKindSel = { link = "PmenuExtraSel" },
  PmenuSel = { fg = darkgrey, bg = yellow },
  Question = { fg = cyan },
  QuickFixLine = { fg = yellow },
  Removed = { fg = red },
  DiffDelete = { link = "Removed" },
  SpellBad = { sp = red, undercurl = true },
  SpellCap = { sp = yellow, undercurl = true },
  SpellLocal = { sp = green, undercurl = true },
  SpellRare = { sp = cyan, undercurl = true },
  Statement = { fg = white, bold = true },
  Operator = { link = "Statement" },
  PreProc = { link = "Statement" },
  Special = { link = "Statement" },
  StatusLine = { fg = white, bg = statuslineBg },
  StatusLineNC = { fg = lightgrey, bg = statuslineBg },
  TabLine = { link = "StatusLineNC" },
  String = { fg = green },
  Title = { fg = white, bold = true },
  Todo = { fg = black, bg = yellow },
  Visual = { bg = selectionBg },
  WarningMsg = { fg = yellow },
  DiagnosticWarn = { link = "WarningMsg" },
  WinSeparator = { fg = darkgrey },
  FloatBorder = { link = "WinSeparator" },
}

vim.cmd.highlight("clear")
vim.g.colors_name = "minimal"

for group, attrs in pairs(colors) do
  vim.api.nvim_set_hl(0, group, attrs)
end
