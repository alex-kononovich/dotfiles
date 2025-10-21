function branch-pr-number -d "Returns PR number for current branch"
  gh pr view --json number --jq '.number'
end
