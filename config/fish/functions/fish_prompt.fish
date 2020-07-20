function fish_prompt --description "Write out the prompt"
    set -l color_cwd
    set -l suffix
    switch $USER
        case root toor
            if set -q fish_color_cwd_root
                set color_cwd $fish_color_cwd_root
            else
                set color_cwd $fish_color_cwd
            end
            set suffix '#'
        case '*'
            set color_cwd $fish_color_cwd
            set suffix '$'
    end

    set -l status_indicator
    set -l current_status $status # somehow if you read status twice it resets to 0
    if test $current_status != 0
      set status_indicator (set_color $fish_color_status)"[$current_status]"(set_color normal)' '
    end
    echo -n -s $status_indicator (set_color $color_cwd) (prompt_pwd) (set_color normal) " $suffix "
end
