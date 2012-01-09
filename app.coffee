# Project: RedditOC
# Author: Zach Fogg - zach.fogg@gmail.com

treeBuilder = (root, brancher) ->
    {
        leaf: root,
        branches: treeBuilder branch, brancher for branch in brancher root
    } # A branch's end is formed with the empty-list base-case.

buildCommentTrees = ->
    topComments = ($ ".commentarea > .sitetable > .comment")
    commentBrancher = (comment) ->
        ($ comment).find(".child > .sitetable > .comment")
    treeBuilder comment, commentBrancher for comment in topComments

authOfC = (comment) ->
    ($ comment).children(".entry").find(".noncollapsed > .tagline > .author")

# An array of all the comments within a thread where the OC is the author.
rootWithinTree = (root) ->
    rootAuth = authOfC(root.leaf).html()
    recur = (branch = root, acc = []) ->
        if authOfC(branch.leaf).html() is rootAuth #and (acc.indexOf branch.leaf) is -1
            acc.push branch.leaf
        if branch.branches and branch.branches.length isnt 0
            recur b, acc for b in branch.branches
        acc
    recur()

#commentCSS = (comment, css) -> authOfC(comment).css css

addClassToAuth = (comment, classToAdd) ->
    ($ authOfC(comment)).addClass classToAdd

mapOCAuths = (f, predicate) ->
    tree = buildCommentTrees()
    commentsByOCAuths = (rootWithinTree b for b in tree)
    f cByOCAuths for cByOCAuths in commentsByOCAuths when predicate cByOCAuths

# Finally, color the comments of the original commenter within his comment thread.
# Predicate: only those who have more than one comment within their thread get colorized.
mapOCAuths ((cs) -> addClassToAuth cs, "OCAuthor"), ((cs) -> cs.length > 1)
