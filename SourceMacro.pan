local Dictionary, ProcedureList
//this saves your procedures into a variable
//step one
saveallprocedures "", Dictionary
clipboard()=Dictionary
//now you can paste those into a text editor and make your changes
STOP
//step 2
//this lets you load your changes back in from an editor and put them in
Dictionary=clipboard()
loadallprocedures Dictionary,ProcedureList
message ProcedureList //messages which procedures got changed
