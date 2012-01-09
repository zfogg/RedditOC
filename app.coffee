# Project: RedditOC
# Author: Zach Fogg - zach.fogg@gmail.com

topComments = ($ ".commentarea > .sitetable > .comment")

treeBuilder = (root, brancher) ->
    {
        leaf: root,
        branches: treeBuilder branch, brancher for branch in brancher root
    }

buildCommentTrees = ->
    commentBrancher = (comment) ->
        ($ comment).find(".child > .sitetable > .comment")
    treeBuilder comment, commentBrancher for comment in topComments
