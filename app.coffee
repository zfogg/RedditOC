# Project: RedditOC
# Author: Zach Fogg - zach.fogg@gmail.com

topComments = ($ ".commentarea > .sitetable > .comment")

#(e.id = ($ e).attr "data-fullname" for e in topComments) # Makes all top comments easy to access.
#topAuthors = (
#    {
#        comment: e,
#        author: ($ "#"+e.id+" > .entry > .noncollapsed > .tagline > .author").html()
#    } for e in topComments
#)

childAuthors = (comment) ->
    children = ($ comment).find(".child > .sitetable > .comment")
    if children is []
        []
    else
        {
            comment: comment
            children: (childAuthors child for child in children)
        }

commentTree = (childAuthors comment for comment in topComments)
