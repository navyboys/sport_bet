# Homepage (Root path)
get '/' do
  flash[:notice] = "You're welcome."
  erb :index
end
