require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require 'find'
require 'yaml'

helpers do
  def in_paragraphs(content)
    content.split("\n\n").each_with_index.map do |paragraph, index|
      "<p id=paragraph#{index}>#{paragraph}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, "<strong>#{term}</strong>")
  end

  def count_interests(users)
    users.reduce(0) { |sum, (name, user)| sum + user[:interests].length }
  end
end

def each_chapter(&block)
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end

before do
  @title = 'The Adventures of Sherlock Holmes'
  @contents = File.readlines('data/toc.txt')

  @users = YAML.load_file('users.yaml')
end

not_found do
  redirect "/"
end

get "/users" do
  erb :users
end

get "/user/:name" do
  @user_name = params[:name].to_sym
  @email = @users[@user_name][:email]
  @interests = @users[@user_name][:interests]

  erb :user
end

get "/" do
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  ch_name = @contents[number - 1]
  @ch_title = "Chapter #{number}: #{ch_name}"

  @content = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do
  # @query = params[:query]
  # @results = []

  # if @query
  #   ch_total = Dir.glob("data/chp*.txt").length

  #   ch_total.times do |i|
  #     content = File.read("data/chp#{i + 1}.txt")

  #     if content.include?(@query)
  #       @results << "<a href='/chapters/#{i + 1}'>#{@contents[i]}</a>"
  #     end
  #   end
  # end

  @results = chapters_matching(params[:query])

  erb :search
end

get "/show/:name" do
  params[:name]
end
