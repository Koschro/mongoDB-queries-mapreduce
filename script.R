#R-MongoDB
#1.- Install and load the package rmongodb
install.packages("rmongodb")
library(rmongodb)
  
#2.- Open a connection to mongo and store the object in an object called mongo
mongo = mongo.create()
  
#3.- Check that you are connected to your mongo installation
mongo.is.connected(mongo)
  
#4.- Create a string namespace variable to represent a mongo collection "lab2" in a database "r"
ns <- "r.lab2"
  
#5.- Create a JSON string variable to represent a person whose name is Cristiano and whose language is Portuguese. 
JSON_string<-'{"name":"Cristiano", "language":"Portugese"}'
  
#6.- Insert Cristiano into your MongoDB database and save the result of the call into a variable called ok
bson <- mongo.bson.from.JSON(JSON_string)
ok<-mongo.insert(mongo, ns, bson)
mongo.find.all(mongo, ns)
  
#7.- Create two new BSON objects to represent Ioanna, whose language is English and her age is 34, and Dimitris, whose language is Greek and his age is 29
#Mongo_shell
#use	r
#db.lab2.find()

#R
bson1 <- mongo.bson.from.JSON('{"name":"Ioanna", "language":"English","age":34}')
bson2 <- mongo.bson.from.JSON('{"name":"Dimitris","language":"Greek", "age":29}')
  
#8.- Insert Ioanna and Dimitris in the database and use both the result of the call as well as the mongo shell to make sure you were successful
#R
ok<-mongo.insert.batch(mongo, ns ,list(bson1, bson2))
mongo.find.all(mongo, ns)

#Mongo_shell
#db.lab2.find()
  
#9.- Update Cristiano so that he now has an age of 26. Once again check your results both in R and in Mongo

#R
mongo.update(mongo, ns , '{"name":"Cristiano"}','{"name":"Cristiano","language":"Portugese", "age":26}')
mongo.find.all(mongo, ns,query='{"name":"Cristiano"}')

#Mongo_shell
#db.lab2.find({"name":"Cristiano"})

  
#10.- Remove Dimitris from the database. Once again check your results both in R and in Mongo
#R
mongo.remove(mongo, ns , '{"name":"Dimitris"}')
mongo.find.all(mongo, ns)

#Mongo_shell
#db.lab2.find()

  
#11.- Add some more people into the collection. Then, extract all the people from the collection using the code just given, and store them into a data frame.
#R
bson3 <- mongo.bson.from.JSON('{"name":"Juan", "language":"Spanish","age":22}')
bson4 <- mongo.bson.from.JSON('{"name":"Tom","language":"English", "age":39}')
bson5 <- mongo.bson.from.JSON('{"name":"Katerina", "language":"Russian","age":24}')
bson6 <- mongo.bson.from.JSON('{"name":"Jason","language":"English", "age":25}')
ok<-mongo.insert.batch(mongo, ns ,list(bson3, bson4, bson5, bson6))
mongo.find.all(mongo, ns)

library(plyr) #required for the rbind.fill
cursor <- mongo.find(mongo, ns)
current_row_number <- 0
export = data.frame()
while(mongo.cursor.next(cursor)) {
  current_row_number<- current_row_number+1
  current_row<- mongo.bson.to.list(mongo.cursor.value(cursor))
  current_row.df = as.data.frame(t(unlist(current_row)))
  export = rbind.fill(export, current_row.df[-1]) #exclude the id column
}
export

  
#12.- Write a function to store the contents of the heart data frame into a heart collection. 
#R
library(robustbase)	#required for the heart data
data(heart)
nc<-"r.heart"
myfunction <- function(x){
  b = mongo.bson.from.df(x)
  mongo.insert.batch(mongo,nc,b)
}
myfunction(heart)
mongo.find.all(mongo, nc)

#Mongo_shell
#db.heart.find()
  
#13._ Close your MongoDB connection.
mongo.destroy(mongo)