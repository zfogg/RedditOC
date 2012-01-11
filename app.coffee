# Project: RedditOC
# Author: Zach Fogg - zach.fogg@gmail.com

# jQuery:
ORIGINAL_COMMENTS = ".commentarea > .sitetable > .comment"
CHILD_COMMENTS    = ".child > .sitetable > .comment"
COMMENT_DATA      = ".entry"
DATA_AUTHOR       = ".noncollapsed > .tagline > .author"

# Element meta:
OC_AUTHOR_CLASS     = "OCAuthor"
UNIQUE_COMMENT_ATTR = "data-fullname"

dataTree = (root, brancher) ->
        leaf: root,
        branches: dataTree branch, brancher for branch in brancher root

# An array of leaves from the tree whose leafProp match the rootProp.
rootInTree = (root, leafProp, leafSig) ->
    rootProp = leafProp root.leaf

    recur = (branch, acc, sigs) ->
        branchSig = leafSig branch.leaf
        if (leafProp branch.leaf) is rootProp and not sigs[branchSig]
            sigs[branchSig] = true
            acc.push branch.leaf
        recur b, acc, sigs for b in branch.branches
        acc

    recur root, [], {}

mapRootsInTrees = (f, predicate, leafProp, leafSig, trees) ->
    rootsInTrees = (rootInTree t, leafProp, leafSig for t in trees)
    f roots for roots in rootsInTrees when predicate roots

commentTrees = (brancher) ->
    dataTree oc, brancher for oc in ($ ORIGINAL_COMMENTS)

authOfC = (comment) ->
    (($ comment).children COMMENT_DATA).find DATA_AUTHOR

            # Map Function - Adds a CSS class.
mapRootsInTrees ((comments) -> ($ authOfC comments).addClass OC_AUTHOR_CLASS),

            # Predicate - Threads where the original author comments again.
                ((comments) -> comments.length > 1),

            # Property - Extracts the author's name.
                ((comment) -> (authOfC comment).html()),

            # Signature - Extracts a unique attribute.
                ((comment) -> ($ comment).attr UNIQUE_COMMENT_ATTR),

            # Data Tree - Branches from a comment into its child comments.
                (commentTrees (c) -> ($ c).find CHILD_COMMENTS)
