function main-git-branch --description 'Print GIT_MAIN_BRANCH, or main when unset or empty'
    if test -n "$GIT_MAIN_BRANCH"
        printf '%s\n' "$GIT_MAIN_BRANCH"
    else
        printf '%s\n' main
    end
end
