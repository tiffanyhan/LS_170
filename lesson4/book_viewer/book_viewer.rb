require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require 'find'

get "/" do
  @files = Dir.glob("public/*/*").sort do |a, b|
    File.basename(a) <=> File.basename(b)
  end
  @files.reverse! if params[:sort] == 'desc'

  @files.map! { |file| file.gsub('public/', '') }
  @basenames = @files.map { |file| File.basename(file) }

  erb :list
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  @contents = File.readlines('data/toc.txt')

  erb:home
end

get "/chapters/1" do
  @title = 'Chapter 1'
  @contents = File.readlines('data/toc.txt')

  chapter = File.read('data/chp1.txt')
  @paragraphs = chapter.split("\n\n")

  erb :chapter
end
