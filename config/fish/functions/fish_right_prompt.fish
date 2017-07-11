set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_char_stateseparator ''

set -g __fish_git_prompt_char_cleanstate ''
set -g __fish_git_prompt_char_dirtystate ' *'
set -g __fish_git_prompt_char_stagedstate ' +'
set -g __fish_git_prompt_char_invalidstate ' #'

set -g __fish_git_prompt_char_untrackedfiles ' …'

set -g __fish_git_prompt_char_upstream_equal ''
set -g __fish_git_prompt_char_upstream_ahead ' ↑'
set -g __fish_git_prompt_char_upstream_behind ' ↓'
set -g __fish_git_prompt_char_upstream_diverged ' ⥄ '

set -g __fish_git_prompt_showcolorhints 1
set -g __fish_git_prompt_color_branch normal
set -g __fish_git_prompt_color_upstream yellow

function fish_right_prompt
  __fish_git_prompt '%s'
end

