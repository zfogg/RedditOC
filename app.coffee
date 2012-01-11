# Project: RedditOC
# Author: Zach Fogg - zach.fogg@gmail.com

# Static jQuery strings:
ORIGINAL_COMMENTS = ".commentarea > .sitetable > .comment"
CHILD_COMMENTS    = ".child > .sitetable > .comment"
COMMENT_DATA      = ".entry"
AUTHOR_OF_ENTRY   = ".noncollapsed > .tagline > .author"

# Element meta strings:
OC_AUTHOR_CLASS     = "OCAuthor"
UNIQUE_COMMENT_ATTR = "data-fullname"

treeBuilder = (root, brancher) ->
    {
        leaf: root,
        branches: treeBuilder branch, brancher for branch in brancher root
    } # A branch's end is formed with the empty-list base-case.

buildCommentTrees = ->
    treeBuilder oc, ((c) -> ($ c).find CHILD_COMMENTS) for oc in ($ ORIGINAL_COMMENTS)

# An array of leaves from the tree whose leafProp match the rootProp.
rootInTree = (root, leafProp, leafSig) ->
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
    rootsInTrees = (rootInTree t, leafProp, leafSig for t in trees)
    f roots for roots in rootsInTrees when predicate roots

authOfC = (comment) ->
    (($ comment).children COMMENT_DATA).find AUTHOR_OF_ENTRY

# We will need a few tiny functions to describe what we want:

# Map Function - Adds a CSS class to those comments that satisy the predicate.
classifyOC = (comments) -> ($ authOfC comments).addClass OC_AUTHOR_CLASS

# Predicate - Comments where the original author replies in his comment thread satisfy this.
moreThanOne = (comments) -> comments.length > 1

# Property - Extracts the author's name from a comment.
commentProp = (leaf) -> (authOfC leaf).html()

# Signature - Extracts a unique piece of data from a comment.
commentSig = (leaf) -> ($ leaf).attr UNIQUE_COMMENT_ATTR

# Finally, put it all together:
mapRootsInTrees classifyOC, moreThanOne, commentProp, commentSig, buildCommentTrees()
