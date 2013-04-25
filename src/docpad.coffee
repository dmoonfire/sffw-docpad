# Define the Configuration
docpadConfig = {
  templateData:
    site:
      title: "Science Fiction and Fantasy Women"
      brand: "SFFW"
      windowsTile: "#b98ac6"
      allowIncome: true
      flattrUid: "dmoonfire"
      flattrTags: "knowledge"
      disqus: "sffw"

    getPreparedTitle: -> if @document.Title then "#{@document.title} | #{@site.title}" else @site.title
    getPreparedDescription: -> if @document.Description then "#{@document.Description}" else "None"
    getPreparedKeywords: -> if @document.Description then "#{@document.Description}" else "None"
}

# Export the Configuration
module.exports = docpadConfig
