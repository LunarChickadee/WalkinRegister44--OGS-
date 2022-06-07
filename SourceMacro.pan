local Dictionary, ProcedureList
//this saves your procedures into a variable
//step one
saveallprocedures "", Dictionary
clipboard()=Dictionary
//now you can paste those into a text editor and make your changes
STOP

//step 2
//this lets you load your changes back in from an editor and put them in
//now comment out from step one to step 2
//run the procedure one step at a time to load the list on your clipboard back in
Dictionary=clipboard()
loadallprocedures Dictionary,ProcedureList
message ProcedureList //messages which procedures got changed