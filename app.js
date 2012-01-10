var CHILDREN_COMMENTS, ORIGINAL_COMMENTS, authOfC, buildCommentTrees, classifyOC, commentProp, commentSig, mapRootsInTrees, moreThanOne, rootWithinTree, treeBuilder;

ORIGINAL_COMMENTS = ".commentarea > .sitetable > .comment";

CHILDREN_COMMENTS = ".child > .sitetable > .comment";

treeBuilder = function(root, brancher) {
  var branch;
  return {
    leaf: root,
    branches: (function() {
      var _i, _len, _ref, _results;
      _ref = brancher(root);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        branch = _ref[_i];
        _results.push(treeBuilder(branch, brancher));
      }
      return _results;
    })()
  };
};

buildCommentTrees = function() {
  var commentBrancher, oc, originalComments, _i, _len, _results;
  originalComments = $(ORIGINAL_COMMENTS);
  commentBrancher = function(comment) {
    return ($(comment)).find(CHILDREN_COMMENTS);
  };
  _results = [];
  for (_i = 0, _len = originalComments.length; _i < _len; _i++) {
    oc = originalComments[_i];
    _results.push(treeBuilder(oc, commentBrancher));
  }
  return _results;
};

rootWithinTree = function(root, leafProp, leafSig) {
  var recur, rootProp;
  rootProp = leafProp(root.leaf);
  recur = function(branch, acc, sigs) {
    var b, branchProp, branchSig, _i, _len, _ref;
    branchProp = leafProp(branch.leaf);
    branchSig = leafSig(branch.leaf);
    if (branchProp === rootProp && !sigs[branchSig]) {
      sigs[branchSig] = true;
      acc.push(branch.leaf);
    }
    _ref = branch.branches;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      recur(b, acc, sigs);
    }
    return acc;
  };
  return recur(root, [], {});
};

mapRootsInTrees = function(f, predicate, leafProp, leafSig, trees) {
  var roots, rootsInTrees, t, _i, _len, _results;
  rootsInTrees = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = trees.length; _i < _len; _i++) {
      t = trees[_i];
      _results.push(rootWithinTree(t, leafProp, leafSig));
    }
    return _results;
  })();
  _results = [];
  for (_i = 0, _len = rootsInTrees.length; _i < _len; _i++) {
    roots = rootsInTrees[_i];
    if (predicate(roots)) _results.push(f(roots));
  }
  return _results;
};

authOfC = function(comment) {
  return (($(comment)).children(".entry")).find(".noncollapsed > .tagline > .author");
};

classifyOC = function(cs) {
  return ($(authOfC(cs))).addClass("OCAuthor");
};

moreThanOne = function(cs) {
  return cs.length > 1;
};

commentProp = function(leaf) {
  return (authOfC(leaf)).html();
};

commentSig = function(leaf) {
  return ($(leaf)).attr("data-fullname");
};

mapRootsInTrees(classifyOC, moreThanOne, commentProp, commentSig, buildCommentTrees());
