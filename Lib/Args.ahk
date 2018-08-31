Args(start:=1,end:=0,quote:=True){
    n:=A_Args.length(), a:=""
   ,start:= start>0 ? start         : n-start
   ,end  :=   end>0 ? (end>n?n:end) : n-end
   ,quote:=(quote?'"':'')

    while start<end
        a.=quote A_Args[start++] quote ' '
    if start=end
        a.=quote A_Args[start++] quote
    return a
}