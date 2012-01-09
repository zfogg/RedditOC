var addClassToAuth, authOfC, buildCommentTrees, mapOCAuths, rootWithinTree, treeBuilder;

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
  var comment, commentBrancher, topComments, _i, _len, _results;
  topComments = $(".commentarea > .sitetable > .comment");
  commentBrancher = function(comment) {
    return ($(comment)).find(".child > .sitetable > .comment");
  };
  _results = [];
  for (_i = 0, _len = topComments.length; _i < _len; _i++) {
    comment = topComments[_i];
    _results.push(treeBuilder(comment, commentBrancher));
  }
  return _results;
};

authOfC = function(comment) {
  return ($(comment)).children(".entry").find(".noncollapsed > .tagline > .author");
};

rootWithinTree = function(root) {
  var recur, rootAuth;
  rootAuth = authOfC(root.leaf).html();
  recur = function(branch, acc) {
    var b, _i, _len, _ref;
    if (branch == null) branch = root;
    if (acc == null) acc = [];
    if (authOfC(branch.leaf).html() === rootAuth) acc.push(branch.leaf);
    if (branch.branches && branch.branches.length !== 0) {
      _ref = branch.branches;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        b = _ref[_i];
        recur(b, acc);
      }
    }
    return acc;
  };
  return recur();
};

addClassToAuth = function(comment, classToAdd) {
  return ($(authOfC(comment))).addClass(classToAdd);
};

mapOCAuths = function(f, predicate) {
  var b, cByOCAuths, commentsByOCAuths, tree, _i, _len, _results;
  tree = buildCommentTrees();
  commentsByOCAuths = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = tree.length; _i < _len; _i++) {
      b = tree[_i];
      _results.push(rootWithinTree(b));
    }
    return _results;
  })();
  _results = [];
  for (_i = 0, _len = commentsByOCAuths.length; _i < _len; _i++) {
    cByOCAuths = commentsByOCAuths[_i];
    if (predicate(cByOCAuths)) _results.push(f(cByOCAuths));
  }
  return _results;
};

mapOCAuths((function(cs) {
  return addClassToAuth(cs, "OCAuthor");
}), (function(cs) {
  return cs.length > 1;
}));
