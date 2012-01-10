# Project: RedditOC
# Author: Zach Fogg - zach.fogg@gmail.com

ORIGINAL_COMMENTS =  ".commentarea > .sitetable > .comment"
CHILDREN_COMMENTS =  ".child > .sitetable > .comment"

treeBuilder = (root, brancher) ->
    {
        leaf: root,
        branches: treeBuilder branch, brancher for branch in brancher root
    } # A branch's end is formed with the empty-list base-case.

buildCommentTrees = ->
    originalComments = ($ ORIGINAL_COMMENTS)
    commentBrancher = (comment) ->
        ($ comment).find CHILDREN_COMMENTS
    treeBuilder oc, commentBrancher for oc in originalComments

# An array of leaves from the tree whose leafProp match the rootProp.
rootWithinTree = (root, leafProp, leafSig) ->
    rootProp = leafProp root.leaf
    recur = (branch, acc, sigs) ->
        branchProp = leafProp branch.leaf
        branchSig = leafSig branch.leaf
        if branchProp is rootProp and not sigs[branchSig]
            sigs[branchSig] = true
            acc.push branch.leaf
        recur b, acc, sigs for b in branch.branches
        acc
    recur root, [], {}

mapRootsInTrees = (f, predicate, leafProp, leafSig, trees) ->
    rootsInTrees = (rootWithinTree t, leafProp, leafSig for t in trees)
    f roots for roots in rootsInTrees when predicate roots

authOfC = (comment) ->
    (($ comment).children ".entry").find ".noncollapsed > .tagline > .author"

# We will need a few tiny functions to describe what we want:

# Map Function - Adds a CSS class to those comments that satisy the predicate.
classifyOC = (cs) -> ($ authOfC cs).addClass "OCAuthor"

# Predicate - Comments where the original author replies in his comment thread satisfy this.
moreThanOne = (cs) -> cs.length > 1

# Property - Extracts the author's name from a comment.
commentProp = (leaf) -> (authOfC leaf).html()

# Signature - Extracts a unique piece of data from a comment.
commentSig = (leaf) -> ($ leaf).attr "data-fullname"

# Finally, color the comments of the original commenter within his comment thread.
mapRootsInTrees classifyOC, moreThanOne, commentProp, commentSig, buildCommentTrees()
