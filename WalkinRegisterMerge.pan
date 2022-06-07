//this is just a copy of the JPs version that I used for testing

˛.Initializeˇpermanent lasttime, lasttime2
global creditex, walkin, names, list,num, mtenter, fbenter, sdsenter,ordered,taxable, 
price,quant,tot,item,numb,display,mtordered, fbordered, sdsordered, usedisc,
mtnumb, mtdisplay, fbnumb, fbdisplay, sdsnumb, sdsdisplay, size, Moosetotal, OGStotal, Seedtotal, Treetotal, Seedlingtotal, shippin, shipto, waswindow, Bulbstotal,
ogsitem, mtitem, fbitem, sdsitem, itemlength, entryitem, mtentryitem, fbentryitem, sdsentryitem, recordsize, id_number, mtliveQuery, fbliveQuery, sdsliveQuery, getseedscat, gettreescat, getbulbscat,
walkinname,itemtrans,newitem, catheader
expressionstacksize 75000000
fileglobal liveQuery, queryResults, mad, cit, st, arbico, arbicoinv, invno, mtliveQuery, fbliveQuery, sdsliveQuery, mtqueryResults, fbqueryResults, sdsqueryResults, findinwalkin, findinmailinglist, walkingroup, walkinname, chargeit, giftamount, giftused, orderdisplay
getseedscat=1
gettreescat=1
getbulbscat=1
mtliveQuery=""
fbliveQuery=""
sdsliveQuery=""
liveQuery=""
ogsitem=""
mtenter=""
mtitem=""
fbenter=""
fbitem=""
sdsenter=""
sdsitem=""
;;enter=""
creditex=""
display=""
fbdisplay=""
sdsdisplay=""
mtdisplay=""
entryitem=""
fbentryitem=""
sdsentryitem=""
mtentryitem=""
itemlength=0
Moosetotal=0
Bulbstotal=0
Seedtotal=0
shippin=0
shipto=""
mad=""
cit=""
st=""
arbico=""
arbicoinv=""
invno=""
walkinname=""
itemtrans=0
chargeit=0
orderdisplay=""


walkin=info("windowname")
openfile "44ogscomments.linked"
arraybuild catheader,",", "44ogscomments.linked", headers
arraydeduplicate catheader, catheader, ","
arraysort catheader, catheader, ","

window walkin

;; Sarah, Stasha like this prompt, but no one else does, so leave it commented out by default in the master copy
if folderpath(dbinfo("folder","")) CONTAINS "sarah" or folderpath(dbinfo("folder","")) CONTAINS "stasha"
    yesno "Keep going?"
    If clipboard() contains "no"
        stop
    endif
endif
    
openfile "44WalkInReconciliation"
openfile "44 mailing list"
openfile "44ogscomments.warehouse"
openfile "discounttable"
recordsize=info("records")
;;openfile "44mt prices"
;;select priceline notcontains "no"
;openfile "44MooseOrderingNifelheim"
openfile "44bulbs lookup"
openfile "44seeds prices"
window walkin
forcesynchronize
field Transaction
sortup
lastrecord
goform "sales"
superobject "Categories", "open", "FillList", "Close"
drawobjects
message "Ready"
;superobject "ogsinput", "Open"˛/.Initializeˇ˛.NewRecordˇif Paid=0 and Total>0 and PurchaseOrder="" and TransactionType notcontains "donation" and TransactionType notcontains "transfer" and TransactionType notcontains "owes"
message "Please complete this order"
stop
endif
if
Status="Com"
InsertBelow
else
call .finished
insertbelow
endif˛/.NewRecordˇ˛.addtomailinglistˇopenfile "44 mailing list"
;; first search really thoroughly (by address, by email)

goform "Add Walkin Customer"
insertrecord
inqcode=str(yearvalue(today()))[3,4]+"wi"
S=1
T=1
Bf=1˛/.addtomailinglistˇ˛.addtoordernewˇIf Status contains "com"
stop
endif
local qty, newitem
qty=""
gettext "How many?", qty
if extract(querySelection,¬,1) contains "-"
    newitem=extract(querySelection,"-",1)+ "+" + extract(extract(querySelection,¬,1),"-",2) + "+" + qty
else
    newitem=extract(querySelection,¬,1)+"+"+qty
endif

enter=enter+newitem+¶
qty=""
superobject "OGSEnter", "Open" 
activesuperobject "SetText", enter
activesuperobject "close"
;;superobject "ogsinput", "open"
;;ogsitem=""
ShowPage
stop˛/.addtoordernewˇ˛.arbicoˇ;;debug

;;message arbicoinv
;;Notes="Arbico " + str(arbicoinv) + Notes

arrayfilter Order, arbico,¶, extract(extract(Order,¶,seq()),¬,1)+¬+extract(extract(Order,¶,seq()),¬,2)
+¬+extract(extract(Order,¶,seq()),¬,5)+" "+rep(chr(95),4)
+¬+extract(extract(Order,¶,seq()),¬,3)

printusingform "","arbicopacking"
printonerecord dialog
goform "arbicoinvoice"

;;pdfsetup "Arbico Invoice "+str(arbicoinv)+".pdf"

printonerecord ""
arbico=""

goform "sales"˛/.arbicoˇ˛.customerowesˇlocal deadbeat
deadbeat=""
if info("trigger")="Button.Customer Owes"
TransactionType="Owes"
if Name=""
getscrap "Who owes?"
Name=clipboard()
deadbeat=Name+ " owes"
Notes=?(Notes="",deadbeat,Notes+¶+deadbeat)
else
deadbeat=Name+ " owes"
Notes=?(Notes="",deadbeat,Notes+¶+deadbeat)
endif
endif
˛/.customerowesˇ˛.donationˇ
TransactionType="Donation"
if
Group=""
getscrap "Donation to:"
Notes=?(Notes="","Donation to "+clipboard(),Notes+¶+"Donation to"+clipboard())
else
Notes=?(Notes="", "Donation to "+Group,Notes+¶+"Donation to "+Group)
endif
˛/.donationˇ˛.enterarbicocustomerˇfileglobal arbicoinv
arbicoinv=""

TaxExempt="Y"
Special="Y"
resale="arbico"
Group="Arbico"
call .entry

    local newWindowRect
    newWindowRect=rectanglecenter(
    info("screenrectangle"),
    rectanglesize(1,1,7*72,8*72))
    setwindowrectangle newWindowRect,
    "noHorzScroll noVertScroll noPallette"
    openform "arbicocustomer"
˛/.enterarbicocustomerˇ˛.entryˇwaswindow=info("windowname")

if Date≠today()
    stop
endif
If Status="Com"
    stop
endif

sobulky:
Moosetotal=0
TaxTotal=0
Subtotal=0
OGStotal=0
Seedtotal=0
Treetotal=0
Bulbstotal=0
Seedlingtotal=0
«$Shipping»=0
numb=1
display=""
mtnumb=""
sdsnumb=""
fbnumb=""

loop
    stoploopif enter=""
    item=val(striptonum(extract(extract(enter,¶,numb),chr(43),1)))
    if item=4000
        quant=val(extract(extract(enter,¶,numb),chr(43),2))
        quant=?(quant=0,1, quant)
        id_number=40000
        price=val(extract(extract(enter,¶,numb),chr(43),3))
        tot=quant*price
        Treetotal=Treetotal+tot
        ordered=str(id_number) +¬+str(item)+¬+
            rep(chr(32),15)+"Trees"+¬+
            rep(chr(32),3)+"0#"+¬+
            rep(chr(32), 6-length(str(quant)))+str(quant)+¬+
            rep(chr(32),7-length(pattern(price,"#.##")))+pattern(price,"$#.##")+¬+
            rep(chr(32),8-length(pattern(tot,"#.##")))+pattern(tot,"$#.##")+¶
            display=display+ordered        
    endif
    if item=5000
        quant=val(extract(extract(enter,¶,numb),chr(43),2))
        quant=?(quant=0,1, quant)
        id_number=50000
        price=val(extract(extract(enter,¶,numb),chr(43),3))
        tot=quant*price
        Seedlingtotal=Seedlingtotal+tot
        ordered=str(id_number) +¬+str(item)+¬+
            rep(chr(32),11)+"Seedlings"+¬+
            rep(chr(32),3)+"0#"+¬+
            rep(chr(32), 6-length(str(quant)))+str(quant)+¬+
            rep(chr(32),7-length(pattern(price,"#.##")))+pattern(price,"$#.##")+¬+
            rep(chr(32),8-length(pattern(tot,"#.##")))+pattern(tot,"$#.##")+¶
            display=display+ordered    
    endif
    if item≥8000
        size=extract(extract(enter,¶,numb),chr(43),2)
        size=?(size="", "a",size)
        quant=val(extract(extract(enter,¶,numb),chr(43),3))
        quant=?(quant=0,1, quant)
        price=val(extract(extract(enter,¶,numb),chr(43),4))
        if price=0
            if item≥10000 and item≤30000   ;; look up in the warehouse file
                case Staff="Y"
                    price=lookup("44ogscomments.warehouse","Item",str(item) + "-" + upper(size),"Staff",0,0)
                case Special="Y"
                    price=lookup("44ogscomments.warehouse","Item",str(item) + "-" + upper(size),"NOFA",0,0)
                case Transfer="Y"
                    price=lookup("44ogscomments.warehouse","Item",str(item) + "-" + upper(size),"base",0,0)    
                defaultcase
                    price=lookup("44ogscomments.warehouse","Item",str(item) + "-" + upper(size),"Price",0,0)
                endcase
            else
                case Staff="Y"
                    price=lookup("44ogscomments.linked","Item",str(item) + "-" + upper(size),"Staff",0,0)
                case Special="Y"
                    price=lookup("44ogscomments.linked","Item",str(item) + "-" + upper(size),"NOFA",0,0)
                case Transfer="Y"
                    price=lookup("44ogscomments.linked","Item",str(item) + "-" + upper(size),"base",0,0)
                    
              case SpareText3="Y"
                    price=lookup("44ogscomments.linked","Item",str(item) + "-" + upper(size),"Price",0,0)
                    price=round(price+price*.055,1)
                defaultcase
                    price=lookup("44ogscomments.linked","Item",str(item) + "-" + upper(size),"Price",0,0)
                endcase
            endif
        endif
        if item≥10000 and item≤30000
            id_number=lookup("44ogscomments.warehouse","Item",str(item) + "-" + upper(size),"IDNumber",0,0)
        else
            id_number=lookup("44ogscomments.linked","Item",str(item) + "-" + upper(size),"IDNumber",0,0)
        endif
        
        if item>0 And price=0
            GetScrap "What is the price of "+str(item) + "-" + upper(size)+"?"
            price=val(clipboard())
        endif
        
        tot=quant*price
        
        
        ;; item number
        ordered=str(id_number) +¬+str(item)+"-"+upper(size)+¬+                                                                                     /*item number*/
        ?(item >=10000,""," ")+
         ?(item=8999,
            extract(extract(enter,¶,numb),chr(43),5)[1,19] +
            rep(chr(32),19-length(extract(extract(enter,¶,numb),chr(43),5)[1,19])),
            lookup(?(item≥10000 and item≤30000,"44ogscomments.warehouse","44ogscomments.linked"),"Item",str(item) + "-" + upper(size),"Description","Not OGS",0)[1,23])  +           /*adds description looked up from 44ogscomments.linked*/
           rep(chr(32),23-length(lookup(?(item≥10000 and item≤30000,"44ogscomments.warehouse","44ogscomments.linked"),"Item",str(item) + "-" + upper(size),"Description",
            "Not OGS",0)[1,23]))                                                                                    /*if item number is 8999 or 9999, put some padding and then the manually entered description. Otherwise, add padding. */
            +rep(chr(32),5-length(str(lookup(?(item≥10000 and item≤30000,"44ogscomments.warehouse","44ogscomments.linked"),"Item",str(item) + "-" + upper(size),«Sz.»,
            0,0))))+¬+str(lookup(?(item≥10000 and item≤30000,"44ogscomments.warehouse","44ogscomments.linked"),"Item",str(item) + "-" + upper(size),«Sz.»,
            0,0))+"#"+¬+                                                                                                /*adds spacing for size, and size, from 44ogscomments.linked (manual items get size 0#)*/
            rep(chr(32), 6-length(str(quant)))+str(quant)+¬+
            rep(chr(32),7-length(pattern(price,"#.##")))+pattern(price,"$#.##")+¬+
            rep(chr(32),8-length(pattern(tot,"#.##")))+pattern(tot,"$#.##")+¶
        taxable=tot
        taxable=?(TaxExempt="Y",0,taxable)
        display=display+ordered    
        TaxTotal=TaxTotal+taxable
        OGStotal=OGStotal+tot
    endif
    if item≥7000 and item<8000
        item=val(extract(extract(enter,¶,numb),chr(43),1))
        size=extract(extract(enter,¶,numb),chr(43),2)
        size=?(size="", "a",size)
        quant=val(extract(extract(enter,¶,numb),chr(43),3))
        quant=?(quant=0,1, quant)
        id_number=79999
        price=val(extract(extract(enter,¶,numb),chr(43),4))
        mtnumb=val(extract(extract(enter,¶,numb),chr(43),6))
        if price=0
            case size="a" or size="A"
                price=lookup("44mt prices","Item",item,"priceA",0,0)
               mtnumb=lookup("44mt prices","Item",item,"szA",0,0)
            case size="b" or size="B"
                price=lookup("44mt prices","Item",item,"priceB",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szB",0,0)
            case size="c" or size="C"
                price=lookup("44mt prices","Item",item,"priceC",0,0)                
                mtnumb=lookup("44mt prices","Item",item,"szC",0,0)
            case size="d" or size="D"
                price=lookup("44mt prices","Item",item,"priceD",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szD",0,0)
            case size="e" or size="E"
                price=lookup("44mt prices","Item",item,"priceE",0,0)
               mtnumb=lookup("44mt prices","Item",item,"szE",0,0)
               endcase
        endif
        if Special="Y"
            case size="a" or size="A"
                price=lookup("44mt prices","Item",item,"bulkA",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szA",0,0)
            case size="b" or size="B"
                price=lookup("44mt prices","Item",item,"bulkB",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szB",0,0)
            case size="c" or size="C"
                price=lookup("44mt prices","Item",item,"bulkC",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szC",0,0)
            case size="d" or size="D"
                price=lookup("44mt prices","Item",item,"bulkD",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szD",0,0)
            case size="e" or size="E"
                price=lookup("44mt prices","Item",item,"bulkE",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szE",0,0)
            endcase
        endif
        if Staff="Y"
            case size="a" or size="A"
                price=lookup("44mt prices","Item",item,"staffA",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szA",0,0)
            case size="b" or size="B"
                price=lookup("44mt prices","Item",item,"staffB",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szB",0,0)
            case size="c" or size="C"
                price=lookup("44mt prices","Item",item,"staffC",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szC",0,0)
            case size="d" or size="D"
                price=lookup("44mt prices","Item",item,"staffD",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szD",0,0)
            case size="e" or size="E"
                price=lookup("44mt prices","Item",item,"staffE",0,0)
                mtnumb=lookup("44mt prices","Item",item,"szE",0,0)
            endcase
            
            ;;price=1
        endif
        
        if val(item)>0 And price=0
            GetScrap "What is the priceof "+str(item)+"?"
            price=val(clipboard())
        endif
        
        tot=val(quant)*price
        
        if val(item)=7000
            mtnumb=extract(extract(enter,¶,numb),chr(43),6)
            if size=""
                getscrap "what size is 7000?"
                mtnumb=clipboard()
            endif
        endif
        
       ordered=str(id_number) +¬+str(item)+"-"+upper(size)+¬+" "+
            ?(val(item)=7000,
            rep(chr(32),19-length(extract(extract(enter,¶,numb),"+",6)[1,19]))
            +extract(extract(enter,¶,numb),"+",6)[1,19],
            lookup("44mt prices","Item",item,"Variety","Special",0)[1,23])+¬+ rep(chr(32),23-length(lookup("44mt prices","Item",item,"Variety",
            "Special",0)[1,23]))+
            rep(chr(32),5-length(str(mtnumb)))+str(mtnumb)+"#"+¬+
            rep(chr(32), 6-length(str(quant)))+str(quant)+¬+
            rep(chr(32),7-length(pattern(price,"#.##")))+pattern(price,"$#.##")+¬+
            rep(chr(32),8-length(pattern(tot,"#.##")))+pattern(tot,"$#.##")+¶

            display=display+ordered    
            Moosetotal=Moosetotal+tot
    endif
    
    
    
    
    
    if item≥6000 and item<7000
        item=val(extract(extract(enter,¶,numb),chr(43),1))
        size=extract(extract(enter,¶,numb),chr(43),2)
        size=?(size="", "a",size)
        quant=val(extract(extract(enter,¶,numb),chr(43),3))
        quant=?(quant=0,1, quant)
        id_number=69999
        price=val(extract(extract(enter,¶,numb),chr(43),4))
        fbnumb=val(extract(extract(enter,¶,numb),chr(43),6))
        if price=0
            case size="a" or size="A"
                price=lookup("44bulbs lookup","number",item,"price A",0,0)
                fbnumb=lookup("44bulbs lookup","number",item,"size A",0,0)
            case size="b" or size="B"
                price=lookup("44bulbs lookup","number",item,"price B",0,0)
                fbnumb=lookup("44bulbs lookup","number",item,"size B",0,0)
            case size="c" or size="C"
                price=lookup("44bulbs lookup","number",item,"price C",0,0)                
                fbnumb=lookup("44bulbs lookup","number",item,"size C",0,0)
            case size="d" or size="D"
                price=lookup("44bulbs lookup","number",item,"price D",0,0)
                fbnumb=lookup("44bulbs lookup","number",item,"size D",0,0)
            endcase
        endif
        if Staff="Y"
            case size="a" or size="A"
                price=lookup("44bulbs lookup","number",item,"staff A",0,0)
                fbnumb=lookup("44bulbs lookup","number",item,"size A",0,0)
            case size="b" or size="B"
                price=lookup("44bulbs lookup","number",item,"staff B",0,0)
                fbnumb=lookup("44bulbs lookup","number",item,"size B",0,0)
            case size="c" or size="C"
                price=lookup("44bulbs lookup","number",item,"staff C",0,0)
                fbnumb=lookup("44bulbs lookup","number",item,"size C",0,0)
            case size="d" or size="D"
                price=lookup("44bulbs lookup","number",item,"staff D",0,0)
                fbnumb=lookup("44bulbs lookup","number",item,"size D",0,0)
            endcase
        endif
        
        if val(item)>0 And price=0
            GetScrap "What is the price of "+str(item)+"?"
            price=val(clipboard())
        endif
        
        tot=val(quant)*price
        
        if val(item)=6000
            fbnumb=extract(extract(enter,¶,numb),chr(43),6)
            if size=""
                getscrap "what size is 6000?"
                fbnumb=clipboard()
            endif
        endif
        
       ordered=str(id_number) +¬+str(item)+"-"+upper(size)+¬+" "+
            ?(val(item)=6000,
            rep(chr(32),19-length(extract(extract(enter,¶,numb),"+",6)[1,19]))
            +extract(extract(enter,¶,numb),"+",6)[1,19],
            lookup("44bulbs lookup","number",item,"name","Special",0)[1,23])+¬+ rep(chr(32),23-length(lookup("44bulbs lookup","number",item,"name",
            "Special",0)[1,23]))+
            rep(chr(32),5-length(str(fbnumb)))+str(fbnumb)+¬+
            rep(chr(32), 6-length(str(quant)))+str(quant)+¬+
            rep(chr(32),7-length(pattern(price,"#.##")))+pattern(price,"$#.##")+¬+
            rep(chr(32),8-length(pattern(tot,"#.##")))+pattern(tot,"$#.##")+¶

            display=display+ordered    
            Bulbstotal=Bulbstotal+tot
    endif    
    
    
    if item≥204 and item<5965
        item=val(extract(extract(enter,¶,numb),chr(43),1))
        size=extract(extract(enter,¶,numb),chr(43),2)
        size=?(size="", "a",size)
        quant=val(extract(extract(enter,¶,numb),chr(43),3))
        quant=?(quant=0,1, quant)
        id_number=19999
        price=val(extract(extract(enter,¶,numb),chr(43),4))
        sdsnumb=val(extract(extract(enter,¶,numb),chr(43),6))
        if price=0
            case size="a" or size="A"
                price=lookup("44seeds prices","Item",item,"priceA",0,0)
                sdsnumb=lookup("44seeds prices","Item",item,"szA",0,0)
            case size="b" or size="B"
                price=lookup("44seeds prices","Item",item,"priceB",0,0)
                sdsnumb=lookup("44seeds prices","Item",item,"szB",0,0)
            case size="c" or size="C"
                price=lookup("44seeds prices","Item",item,"priceC",0,0)                
                sdsnumb=lookup("44seeds prices","Item",item,"szC",0,0)
            case size="d" or size="D"
                price=lookup("44seeds prices","Item",item,"priceD",0,0)
                sdsnumb=lookup("44seeds prices","Item",item,"szD",0,0)
            case size="e" or size="E"
                price=lookup("44seeds prices","Item",item,"priceE",0,0)
                sdsnumb=lookup("44seeds prices","Item",item,"szE",0,0)
            case size="k" or size="K"
                price=lookup("44seeds prices","Item",item,"priceK",0,0)
                sdsnumb=lookup("44seeds prices","Item",item,"szK",0,0)
            case size="l" or size="L"
                price=lookup("44seeds prices","Item",item,"priceL",0,0)
                sdsnumb=lookup("44seeds prices","Item",item,"szL",0,0)
            endcase
        endif
        if Staff="Y"




        endif
        
        if val(item)>0 And price=0
            GetScrap "What is the price of "+str(item)+"?"
            price=val(clipboard())
        endif
        
        tot=val(quant)*price
        
        if val(item)=1000
            sdsnumb=extract(extract(enter,¶,numb),chr(43),6)
            if size=""
                getscrap "what size is 1000?"
                sdsnumb=clipboard()
            endif
        endif
        
       ordered=str(id_number) +¬+str(item)+"-"+upper(size)+¬+" "+
            ?(val(item)=1000,
            rep(chr(32),19-length(extract(extract(enter,¶,numb),"+",6)[1,19]))
            +extract(extract(enter,¶,numb),"+",6)[1,19],
            lookup("44seeds prices","Item",item,"Description","Special",0)[1,23])+¬+ rep(chr(32),23-length(lookup("44seeds prices","Item",item,"Description",
            "Special",0)[1,23]))+
            rep(chr(32),5-length(str(sdsnumb)))+str(sdsnumb)+¬+
            rep(chr(32), 6-length(str(quant)))+str(quant)+¬+
            rep(chr(32),7-length(pattern(price,"#.##")))+pattern(price,"$#.##")+¬+
            rep(chr(32),8-length(pattern(tot,"#.##")))+pattern(tot,"$#.##")+¶

            display=display+ordered    
            debug
            Seedtotal=Seedtotal+tot
    endif    
    
    
    
    
    numb=numb+1
stoploopif numb>arraysize(strip(enter),¶)
while forever


ArraySort display,display,¶
Order=display
Order=arraystrip(Order,¶)
ArrayFilter Order, orderdisplay, ¶,rep(chr(32),3)+arraydelete(extract(Order,¶,seq()),1,1,¬)

Subtotal=OGStotal+Moosetotal+Bulbstotal+Seedtotal+Treetotal+Seedlingtotal
local quien,submarine
quien=0
submarine=0
;; if there is a customer number in the walk-in record, then search for it in the discount table grab the TotalPurchases value.
if «C#»>0
    quien=«C#»
    window "discounttable"
    find «C#»=quien
    if info("found")=0
        window waswindow
    else
        submarine=TotalPurchases
        window waswindow
    endif
endif

if (OGStotal≥2500 or OGStotal+submarine≥2500) and Special≠"Y" and TransactionType≠"Transfer" and Staff≠"Y"
    Special="Y"
    goto sobulky
endif

«%Discount»=?(OGStotal+submarine≥1200,.20,?(OGStotal+submarine≥600,.15,?(OGStotal+submarine≥300,.1,?(OGStotal+submarine≥100,.05,0))))
«%Discount»=?(Special="Y" or Staff="Y" or Transfer="Y",0, «%Discount»)
«OGSTallyDiscount»=?(Special="Y" or Staff="Y" or SpareText3="Y" or Transfer="Y",0, «OGSTallyDiscount»)

if MTDiscount = 1
    goto gotfreepotatoes
endif

MTDiscount=?(Moosetotal≥1200, .20, ?(Moosetotal≥600, .15,?(Moosetotal≥300, .10,?(Moosetotal≥100,.05,0))))
if MTDiscount < 1
    ;; for Tree Sale
    MTDiscount=0  
endif

if (Special="Y" or Staff="Y") and MTDiscount < 1
    MTDiscount=0
endif

FBDiscount=?(Bulbstotal≥1200, .20, ?(Bulbstotal≥600, .15,?(Bulbstotal≥300, .10,?(Bulbstotal≥100,.05,0))))

if (Staff="Y")
    FBDiscount=0
endif

debug

SDSDiscount=?(Seedtotal≥1200, .20, ?(Seedtotal≥600, .15,?(Seedtotal≥300, .10,?(Seedtotal≥100,.05,0))))
if (Staff="Y")
    SDSDiscount=0.5
endif


gotfreepotatoes:

Discount=OGStotal*max(«%Discount»,OGSTallyDiscount)+Moosetotal*MTDiscount+Bulbstotal*FBDiscount+Seedtotal*SDSDiscount
MemberDiscount=?(Member="Y",float(Subtotal)*float(.01),0)
Adjtotal=Subtotal-Discount-MemberDiscount
SalesTax=round(float(Adjtotal)*float(.055)+.0001,.01)

if TaxExempt="Y"
    SalesTax=0
endif

Total=Adjtotal+SalesTax+BalanceDue+«$Shipping»
SeedSales=?(Member="Y",Seedtotal-Seedtotal*(SDSDiscount+.01),Seedtotal*SDSDiscount)
TreeSales=Treetotal
SeedlingSales=Seedlingtotal
OGSSales=?(Member="Y",OGStotal-OGStotal*(«%Discount»+.01),OGStotal-OGStotal*«%Discount»)
MooseSales=?(Member="Y",Moosetotal-Moosetotal*(MTDiscount+.01),Moosetotal*MTDiscount)
BulbsSales=?(Member="Y",Bulbstotal-Bulbstotal*(FBDiscount+.01),Bulbstotal*FBDiscount)

case Staff="Y"
    Notes=?(Notes notcontains "Staff Prices", "Staff Prices applied.",Notes)
case Special="Y"
    ;Notes=?(Notes notcontains "Bulk Prices", Notes+¶+specialname+" gets Bulk Prices",Notes)
    Notes=?(Notes notcontains "Bulk", Notes+¶+"Bulk price, no additional discount applies to OGS items.", Notes)
 case Transfer="Y"
    Notes=?(Notes notcontains "transfer", Notes+¶+"Transfer to "+Name, Notes)
endcase

save   				
drawobjects
if OGStotal>=100 and Name="" and Group=""
    message "Search for customer in discount table and mailing list"
endif˛/.entryˇ˛.fbaddtoorderˇlocal fbqty, fbsz, newitem
fbqty=""
fbsz=""
gettext "How many", fbsz
;gettext "How many?", fbqty
newitem=extract(fbquerySelection,¬,1)+"+"+extract(fbquerySelection,¬,2)+"+"+fbsz
enter=enter+newitem+¶
fbqty=""
fbsz=""
superobject "OGSEnter", "Open" 
activesuperobject "SetText", enter
activesuperobject "close"
;superobject "fbinput", "open"
ShowPage˛/.fbaddtoorderˇ˛.fbfindˇnoshow
if val(fbitem)≥6000 and val(fbitem) < 7000
    fborderitem=fbitem+¬
    fbitem=""
    call ".fbaddtoorder"
endif
waswindow=info("windowname")
window "44bulbs lookup:Secret"
select name contains fbitem
arrayselectedbuild fbentryitem, ¶, info("databasename"), str(number)+¬+name
selectall
window waswindow
showpage
fbitem=""
endnoshow
˛/.fbfindˇ˛.fbLiveQueryˇcase val(fbliveQuery) > 0
    liveclairvoyance fbliveQuery, fbqueryResults, ¶, "FB Query List", "44bulbs lookup", str(Item), "", 
    arraysort(
    ?(«price A» > 0, str(number)+¬+"A"+¬+name+chr(44),"")
    +?(«price B» > 0, str(number)+¬+"B"+¬+name+chr(44),"")
    +?(«price C» > 0, str(number)+¬+"C"+¬+name+chr(44),"")
    +?(«price D» > 0, str(number)+¬+"D"+¬+name+chr(44),""),chr(44)), 
    10,0,"selected"
defaultcase
    liveclairvoyance fbliveQuery, fbqueryResults, ¶, "FB Query List", "44bulbs lookup", name, "", arraysort(
    ?(«price A» > 0, str(number)+¬+"A"+¬+name+chr(44),"")
    +?(«price B» > 0, str(number)+¬+"B"+¬+name+chr(44),"")
    +?(«price C» > 0, str(number)+¬+"C"+¬+name+chr(44),"")
    +?(«price D» > 0, str(number)+¬+"D"+¬+name+chr(44),""),chr(44)), 10,0,"selected"   
endcase

superobject "FB Query List", "FillList"˛/.fbLiveQueryˇ˛.finishedˇif Status="Com"
stop
endif
if Paid=0 and Total>0 and PurchaseOrder="" and TransactionType notcontains "Donation" and TransactionType notcontains "trans" and TransactionType notcontains "owes"
    Message "Please complete the sale"
    stop    
endif
if TransactionType=""
message "Set Transaction Type"
stop
endif
Status="Com"

if TransactionType="PurchaseOrder" or TransactionType="Owes" and email=""
;if «C#»>0, email=lookup("discounttable","C#",«C#»,"email","",0)
;else
    gettext "Email Invoice To:",email
;endif
endif

if TransactionType≠"PurchaseOrder" and (Notes contains "PO" or Notes contains "purchase order")
    Notes=replace(Notes,"PO","")
    Notes=replace(Notes,"purchase order","")
endif
if TransactionType≠"Donation" and Notes contains "donation"
    Notes=replace(Notes,"Donation","")
endif

if TransactionType="Transfer"
    Paid=Total
endif

if «C#»>0
    local quien,totalitarian
    quien=«C#»
    totalitarian=(OGSSales/(OGSSales+MooseSales+BulbsSales+SeedSales))*Subtotal
    window "discounttable"
    selectall
    select «C#»=quien
    if info("selected")<info("records")
        thisyearwalkinpurchases=thisyearwalkinpurchases+totalitarian
        field thisyearwalkinpurchases
        copycell
        pastecell
        call discountfill
        selectall
        find «C#»=quien
    else 
        message "Who?"
    endif
endif
window "Walkin Register44:sales"˛/.finishedˇ˛.giftcertificateˇTransactionType="Gift Certifcate"
giftamount=0
giftused= 0
getscrap "What is the value of the gift certifcate?"
giftamount=val(clipboard())
if giftamount≥Total
giftused=Total
else
giftused=giftamount
endif
giftamount=giftamount-giftused
if giftused=Total
Paid=giftused
«Gift_Certificate»=Paid
 getscrap "What's the certificate code?"
 Notes=Notes+¶+"Paid "+pattern(«Gift_Certificate»,"$#.##")+" with gift certifcate "+clipboard()+" amount left "+str(giftamount)
message "Adjust the certificate online"
applescript |||
		  tell application "Firefox"
			 activate 
    open location "https://fedcoseeds.com/manage_site/gift-certificates"
 end tell  |||
 else
 Paid=giftused
 «Gift_Certificate»=Paid
  getscrap "What's the certificate code?"
 Notes=Notes+¶+"Paid "+pattern(«Gift_Certificate»,"$#.##")+" with gift certifcate "+clipboard()+" amount left "+str(giftamount)
message "Additional owed "+str(Total-Paid)
 call ".mixedpayment"
 endif

˛/.giftcertificateˇ˛.LiveQueryˇfileglobal liveQuery, queryResults, queryResultsw
;message val(liveQuery)
case val(liveQuery)>0
liveclairvoyance liveQuery, queryResults, ¶, "Query List", "44ogscomments.linked", Item, "contains", str(Item)+¬+Description+¬+str(«Sz.»)+"#"+¬+«unit note», 5,0,""
liveclairvoyance liveQuery, queryResultsw, ¶, "Query Listw", "44ogscomments.warehouse", Item, "contains", str(Item)+¬+Description+¬+str(«Sz.»)+"#"+¬+«unit note», 30,0,""
defaultcase
liveclairvoyance liveQuery, queryResults, ¶, "Query List", "44ogscomments.linked", Description, "contains", str(Item)+¬+Description+¬+str(«Sz.»)+"#"+¬+«unit note», 30,0,""
liveclairvoyance liveQuery, queryResultsw, ¶, "Query Listw", "44ogscomments.warehouse", Description, "contains", str(Item)+¬+Description+¬+str(«Sz.»)+"#"+¬+«unit note», 30,0,""
endcase
superobject "Query List", "FillList"
superobject "Query Listw", "FillList"˛/.LiveQueryˇ˛.memberˇif info("activesuperobject")≠""
activesuperobject "close"
endif
call ".entry"˛/.memberˇ˛.mixedpaymentˇfileglobal tendered, change, addpay, paychoice
addpay=0
TransactionType="Mixed"
loop
tendered=0
popup "Cash"+¶+"Check"+¶+"Credit Card"+¶+"Gift Certificate", 175, 470, "Cash", paychoice
case paychoice="Cash"
gettext "Amount from Customer", tendered
Cash=Cash+val(tendered)
Paid=Paid+Cash
case paychoice="Check"
gettext "Amount of Check", tendered
Check=Check+val(tendered)
Paid=Paid+Check
case paychoice="Credit Card"
gettext "Amount of charge", tendered
CreditCard=CreditCard+val(tendered)
Paid=Paid+CreditCard
case paychoice="Gift Certificate"
giftamount=0
giftused=0
getscrap "What is the value of the gift certifcate?"
giftamount=val(clipboard())
gettext "Amount used", tendered
if val(tendered)>giftamount
message "that won't work"
stop
endif
Gift_Certificate=Gift_Certificate+val(tendered)
giftused=val(tendered)
giftamount=giftamount-giftused
Paid=Paid+Gift_Certificate
 getscrap "What's the certificate code?"
 Notes=Notes+¶+"Paid "+pattern(«Gift_Certificate»,"$#.##")+" with gift certifcate "+clipboard()+" amount left "+pattern(giftamount,"$#.##")
endcase
change=Paid-Total
if change>0
message "Change is "+pattern(change,"#.##")
Paid=Paid-change
Cash=Cash-change
endif

stoploopif Paid≥Total
message "Need "+pattern(abs(change),"$#.##")+" more"
repeatloopif change<0
while forever

case Cash+Check+CreditCard+«Gift_Certificate»≠Total
message "Math is off, please double-check"
endcase
case Check<0 or CreditCard<0 or «Gift_Certificate»<0
message "Something is weird, check the math"
endcase
case «Gift_Certificate»>0
message "Adjust the value of the gift certificate online"
applescript |||
		  tell application "Firefox"
			 activate 
    open location "https://fedcoseeds.com/manage_site/gift-certificates"
 end tell  |||
 endcase

˛/.mixedpaymentˇ˛.mtaddtoorderˇlocal mtqty, mtsz, newitem
mtqty=""
mtsz=""
gettext "How many", mtsz
;gettext "How many?", mtqty
newitem=extract(mtquerySelection,¬,1)+"+"+extract(mtquerySelection,¬,2)+"+"+mtsz
enter=enter+newitem+¶
mtqty=""
mtsz=""
superobject "OGSEnter", "Open" 
activesuperobject "SetText", enter
activesuperobject "close"
;superobject "mtinput", "open"
ShowPage˛/.mtaddtoorderˇ˛.mtfindˇnoshow
if val(mtitem)≥7000
mtorderitem=mtitem+¬
mtitem=""
call ".mtaddtoorder"
endif
waswindow=info("windowname")
window "44mt prices:Secret"
select Variety contains mtitem
arrayselectedbuild mtentryitem, ¶, info("databasename"), str(Item)+¬+Variety
selectall
window waswindow
showpage
mtitem=""
endnoshow
˛/.mtfindˇ˛.mtLiveQueryˇcase val(mtliveQuery) > 0
    liveclairvoyance mtliveQuery, mtqueryResults, ¶, "MT Query List", "44mt prices", str(Item), "", 
    arraysort(
    ?(priceA > 0, str(Item)+¬+"A"+¬+Variety+chr(44),"")
    +?(priceB > 0, str(Item)+¬+"B"+¬+Variety+chr(44),"")
    +?(priceC > 0, str(Item)+¬+"C"+¬+Variety+chr(44),"")
    +?(priceD > 0, str(Item)+¬+"D"+¬+Variety+chr(44),"")
    +?(priceE > 0,str(Item)+¬+"E"+¬+Variety+chr(44),""),chr(44)), 
    10,0,"selected"
defaultcase
    liveclairvoyance mtliveQuery, mtqueryResults, ¶, "MT Query List", "44mt prices", Variety, "", arraysort(
    ?(priceA > 0, str(Item)+¬+"A"+¬+Variety+chr(44),"")
    +?(priceB > 0, str(Item)+¬+"B"+¬+Variety+chr(44),"")
    +?(priceC > 0, str(Item)+¬+"C"+¬+Variety+chr(44),"")
    +?(priceD > 0, str(Item)+¬+"D"+¬+Variety+chr(44),"")
    +?(priceE > 0,str(Item)+¬+"E"+¬+Variety+chr(44),""),chr(44)), 10,0,"selected"   
endcase

superobject "MT Query List", "FillList"˛/.mtLiveQueryˇ˛.newchargeˇPaid=Total
TransactionType="CC"
message "Use the Square!"


  
 

		
˛/.newchargeˇ˛.newmtaddtoorderˇlocal mtqty, mtsz, newitem
mtqty=""
mtsz=""

gettext "Enter size and quantity separated by a space: d 4", mtqty
newitem=extract(mtorderitem,¬,1)+"+"+extract(mtqty," ",1)+"+"+extract(mtqty," ",2)
enter=enter+newitem+¶
mtqty=""
mtsz=""
superobject "OGSEnter", "Open" 
activesuperobject "SetText", enter
activesuperobject "close"
superobject "mtinput", "open"
ShowPage˛/.newmtaddtoorderˇ˛.newmtpoplistˇglobal mtitemlist, mtorderitem, thiswindow
thiswindow=info("windowname")
mtorderitem=""
mtitemlist=""
window "44mt prices:secret"
select Variety["A-Z";1]=mtstringer
arrayselectedbuild mtitemlist, ¶, "44mt prices", Variety+¬+str(Item)
arraysort mtitemlist, mtitemlist, ¶
arrayfilter mtitemlist, mtitemlist, ¶, arrayreverse(extract(mtitemlist,¶, seq()),¬)
window thiswindow
popupclick mtitemlist,"", mtorderitem

if mtorderitem=""
    stop
endif

call ".newmtaddtoorder"
˛/.newmtpoplistˇ˛.newpoplistˇglobal itemlist, orderitem, thiswindow
thiswindow=info("windowname")
orderitem=""
itemlist=""


window "44ogscomments.linked:secret"
select headers=header
Selectwithin headers<>""
arrayselectedbuild itemlist, ¶, "44ogscomments.linked",«unit note»+¬+?(«Sz.»>0,str(«Sz.»)+"#","")+¬+Description+¬+str(Item)
arrayfilter itemlist, itemlist, ¶, arrayreverse(extract(itemlist,¶, seq()),¬)
arraysort itemlist, itemlist, ¶
window thiswindow
popupclick itemlist,"", orderitem
if orderitem=""
;Message "Nothing Selected"
stop
endif

querySelection = orderitem
call ".addtoordernew"
˛/.newpoplistˇ˛.newwalkinfindˇlocal findinwalkin, findinmailinglist

case info("ActiveSuperObject")="WalkinName"
    liveclairvoyance walkinname, findinwalkin,¶,"specialpersonlist", "discounttable", Con, "contains", str(«C#»)+¬+Group+¬+Con,10,0,""
    liveclairvoyance walkinname, findinmailinglist,¶,"mailinglistlist", "44 mailing list", Con, "contains", str(«C#»)+¬+Group+¬+Con+"-"+City+" "+St,10,0,""
case info("ActiveSuperObject")="WalkinGroup"
    liveclairvoyance walkingroup, findinwalkin,¶,"specialpersonlist", "discounttable", Group, "contains", str(«C#»)+¬+Group+¬+Con,10,0,""
    liveclairvoyance walkingroup, findinmailinglist,¶,"mailinglistlist", "44 mailing list", Group, "contains", str(«C#»)+¬+Group+¬+Con+"-"+City+" "+St,10,0,""
endcase˛/.newwalkinfindˇ˛.ogsfindˇlocal PopTop, PopLeft
noshow
if val(ogsitem)>8000
    orderitem=ogsitem+¬
    ogsitem=""
    call ".addtoorder"
endif

waswindow=info("windowname")

liveclairvoyance ogsitem, entryitem, ¶, "ogspopup", "44ogscomments.linked", Description, "", ?(headers="","",str(Item)+¬+Description+¬+str(«Sz.»)), 0,0,""
if arraysize(entryitem,¶)=recordsize
    YesNo "Try again?"
    If info("trigger")="Yes"
        superobject "ogslist", "open"
    endif
endif
window waswindow

superobject "ogspopup", "FIllList"
showpage
ogsitem=""
endnoshow˛/.ogsfindˇ˛.openaddressˇsetwindowrectangle rectanglesize(704,1267,347,528),""
openform "CollectAddress"˛/.openaddressˇ˛.openremindmeˇsetwindowrectangle rectanglesize(504,1067,280,600),""
openform "Remindme"˛/.openremindmeˇ˛.paidcashˇfileglobal tendered, change, addpay, paychoice
tendered=0
addpay=0
popup "Cash"+¶+"Check"+¶+"Money Order", 150, 500, "Cash", paychoice

TransactionType=paychoice


if paychoice="Cash"
gettext "Amount from Customer", tendered
change=val(tendered)-Total
if change<0
message "Need "+pattern(abs(change),"$#.##")+" more"
gettext "Additional payment", addpay
tendered=str(val(tendered)+val(addpay))
change=val(tendered)-Total
message "Change is "+pattern(change,"$#.##")
else
if change>0
message "Change is "+pattern(change,"$#.##")
endif
endif
endif
Paid=Total
stop˛/.paidcashˇ˛.paidowedˇPaid=MoneyTendered
«Date Paid»=today()
if Notes contains "owes"
Notes=replace(Notes, " owes", " paid "+datepattern(today(), "mm/dd/yy"))
endif
PurchaseOrder=replace(PurchaseOrder, "owes","")
if Notes contains "purchase order" 
Notes=Notes+¶+"paid "+datepattern(today(), "mm/dd/yy")
endif
TransactionType=""
message "Set Transacton Type"˛/.paidowedˇ˛.poplistˇglobal itemlist, orderitem, thiswindow
thiswindow=info("windowname")
orderitem=""
itemlist=""
window "44ogscomments.linked:secret"
select headers=header
arrayselectedbuild itemlist, ¶, "44ogscomments.linked", str(Item)+¬+Description+¬+str(«Sz.»)+"#"+¬+«unit note»
window thiswindow
popupclick itemlist,"", orderitem
if orderitem=""
stop
endif
call ".addtoordernew"
˛/.poplistˇ˛.purchaseorderˇif info("trigger")="Button.Purchase Order"
TransactionType="PO"
if Group="" and Name=""
getscrap "Who is using this PO?"
Group=clipboard()
endif
endif
if PurchaseOrder="" 
gettext "What is the PO #?",PurchaseOrder
endif
Notes=?(Group≠"", Group, Name)+" PO "+str(PurchaseOrder)

˛/.purchaseorderˇ˛.recordcustomerˇglobal waswindow
waswindow=info("windowname")

if ChosenOne=""
    message "oops!"
    stop
endif

if info("trigger") = "specialpersonlist"
    ;; customer is already in the discount table, so take their info from there
    
    window "discounttable"
    selectall
    find «C#»=val(extract(ChosenOne,¬,1))
    
    window waswindow
    OGSTallyDiscount=grabdata("discounttable",Discount)

    window "discounttable:secret"
    if Bulk=1
        window waswindow
        Special="Y"
        window "discounttable:secret"
    endif
    
else
    ;; customer is in the mailing list but not in the discount table, so:
    ;; copy mailing list record into discount table
    ;; gather any extra info (like if they're staff)
    ;; copy C# into walk-in record
    
    window "44 mailing list:secret"
    select «C#»=val(extract(ChosenOne,¬,1))
    window "discounttable"
    call "addrecord/7"
endif

window waswindow
«C#»=grabdata("discounttable",«C#»)
Name=grabdata("discounttable",Con)
Group=grabdata("discounttable",Group)
window "discounttable:secret"

if TaxExempt=1
    window waswindow
    TaxExempt="Y"
    resale=grabdata("discounttable",TaxID)
    if resale=""
        getscrap "What's Your Tax ID?"
        if clipboard()=""
            resale="9999"
        else
             resale=clipboard()
        endif
    endif
    window "discounttable:secret"
endif
    
if Mem=1
    window waswindow
    Member="Y"
    window "discounttable:secret"
endif
    
if Staff=1
    window waswindow
    Staff="Y"
endif

window waswindow

call ".entry"˛/.recordcustomerˇ˛.sdsaddtoorderˇlocal sdsqty, sdssz, newitem
sdsqty=""
sdssz=""
gettext "How many", sdssz
;gettext "How many?", sdsqty
newitem=extract(sdsquerySelection,¬,1)+"+"+extract(sdsquerySelection,¬,2)+"+"+sdssz
enter=enter+newitem+¶
sdsqty=""
sdssz=""
superobject "OGSEnter", "Open" 
activesuperobject "SetText", enter
activesuperobject "close"
;superobject "sdsinput", "open"
ShowPage˛/.sdsaddtoorderˇ˛.sdsfindˇnoshow
if val(sdsitem)≥200 and val(sdsitem)<6000
sdsorderitem=sdsitem+¬
sdsitem=""
call ".sdsaddtoorder"
endif
waswindow=info("windowname")
window "44seeds prices:Secret"
select Description contains sdsitem
arrayselectedbuild sdsentryitem, ¶, info("databasename"), str(Item)+¬+Description
selectall
window waswindow
showpage
sdsitem=""
endnoshow
˛/.sdsfindˇ˛.sdsLiveQueryˇcase val(sdsliveQuery) > 0
    liveclairvoyance sdsliveQuery, sdsqueryResults, ¶, "SDS Query List", "44seeds prices", str(Item), "", 
    arraysort(
    ?(priceA > 0, str(Item)+¬+"A"+¬+Description+chr(44),"")
    +?(priceB > 0, str(Item)+¬+"B"+¬+Description+chr(44),"")
    +?(priceC > 0, str(Item)+¬+"C"+¬+Description+chr(44),"")
    +?(priceD > 0, str(Item)+¬+"D"+¬+Description+chr(44),"")
    +?(priceE > 0,str(Item)+¬+"E"+¬+Description+chr(44),"")
    +?(priceK > 0,str(Item)+¬+"K"+¬+Description+chr(44),"")
    +?(priceL > 0,str(Item)+¬+"L"+¬+Description+chr(44),""),chr(44)), 
    10,0,"selected"
defaultcase
    liveclairvoyance sdsliveQuery, sdsqueryResults, ¶, "SDS Query List", "44seeds prices", Description, "", arraysort(
    ?(priceA > 0, str(Item)+¬+"A"+¬+Description+chr(44),"")
    +?(priceB > 0, str(Item)+¬+"B"+¬+Description+chr(44),"")
    +?(priceC > 0, str(Item)+¬+"C"+¬+Description+chr(44),"")
    +?(priceD > 0, str(Item)+¬+"D"+¬+Description+chr(44),"")
    +?(priceE > 0,str(Item)+¬+"E"+¬+Description+chr(44),"")
    +?(priceK > 0,str(Item)+¬+"K"+¬+Description+chr(44),"")
    +?(priceL > 0,str(Item)+¬+"L"+¬+Description+chr(44),""),chr(44)), 10,0,"selected"   
endcase

superobject "SDS Query List", "FillList"˛/.sdsLiveQueryˇ˛.shippingˇgetscrap "What's the shipping?"
«$Shipping»=val(clipboard())
Total=Adjtotal+SalesTax+«$Shipping»+BalanceDue˛/.shippingˇ˛.specialˇ;global specialname

if info("activesuperobject")≠""
activesuperobject "close"
endif

if Special="Y"
    loop
        Getscrapok "Who is getting this deal?"
    repeatloopif clipboard()=""
    stoploopif clipboard()≠""
    while forever
endif

Name=clipboard()



call ".entry"˛/.specialˇ˛.staffˇ;global staffname

if info("activesuperobject")≠""
activesuperobject "close"
endif

if Staff="Y"
    loop
        Getscrapok "Who is getting this deal?"
    repeatloopif clipboard()=""
    stoploopif clipboard()≠""
    while forever
endif

Name=clipboard()

call ".entry"˛/.staffˇ˛.taxexemptˇif info("activesuperobject")≠""
activesuperobject "close"
endif

if TaxExempt="Y" and resale=""
    getscrapok "enter resale number"
    TaxExNo=clipboard()
   ; if resale <>"" and «C#» <> ""
    ;    ;;update TaxEx and resale fields in the mailing list
    ;    post "update", zoyear + " mailing list","C#",val(«C#»),"resale",resale,"TaxEx","Y"
    ;endif
endif

call ".entry"˛/.taxexemptˇ˛(macros)ˇ˛/(macros)ˇ˛next/1ˇfileglobal seller, oldrecord
seller=""
if Paid<Total and Notes notcontains "owes" and TransactionType notcontains "Donation" and TransactionType notcontains "Transfer" and TransactionType notcontains "PO"
   
            Message "Please complete the sale"
            stop

endif


Status="Com"

resynchronize
orderdisplay=""
save
field Transaction
sortup
lastrecord
oldrecord=Transaction
InsertBelow
Transaction=oldrecord+1
Time=timepattern(now(),"HH:MM AM/PM")
enter=""
mtenter=""
mtdisplay=""
fbenter=""
fbdisplay=""
sdsenter=""
sdsdisplay=""
list=""
names=""
Status=""
shippin=0
shipto=""
liveQuery=""
mtliveQuery=""
fbliveQuery=""
sdsliveQuery=""
popup "John Paul"+¶+"Scott"+¶+"Sara Roy"+¶+"Jake"+¶+"Sarah Oliver"+¶+"James"+¶+"Noah"+¶+"Renee"+¶+"Stasha"+¶+"Staff", 125, 1050, "John Paul", seller
Seller=seller
superobject "OGSEnter","Open", "SetText", "", "Close"
superobject "ogsinput", "Open"
drawobjects˛/next/1ˇ˛synchronize/0ˇSynchronize
field Transaction sortup
lastrecord
save˛/synchronize/0ˇ˛findrecord/4ˇfileglobal transno
transno=""
gettext "Which transaction?",transno
selectall
find Transaction=val(transno)˛/findrecord/4ˇ˛spudsales/5ˇglobal waswindow
waswindow=info("windowname")
openfile "MTwalkinsales"
deleteall
window waswindow
field Transaction
sortup
global raya, rayb, num
rayb=""
firstrecord
loop
num=1
loop
stoploopif num=arraysize(Order,¶)+1
raya=extract(extract(Order,¶,num),¬,1)[1,4]+¬+extract(extract(Order,¶,num),¬,1)[6,6]
    +¬+extract(extract(Order,¶,num),¬,1)[7,-2]+¬+extract(extract(Order,¶,num),¬,3)
rayb=rayb+¶+raya
rayb=arraystrip(rayb,¶)
num=num+1
while forever
window "MTwalksales:secret"
openfile "+@rayb"
window waswindow
rayb=""
downrecord
until info("stopped")
goform "sales"
selectall
lastrecord
save
window "MT tree sales"
field Item
select Item<8000 and Item>7000
removeunselected
stop
groupup
field Qty
total
RemoveDetail  "data"
lastrecord
deleterecord
save

˛/spudsales/5ˇ˛ogssales/6ˇglobal waswindow
;Synchronize
lasttime=307665
;stop
waswindow=info("windowname")
openfile "44ogswalkinsales"
window waswindow
field Transaction
sortup
global raya, rayb, num
rayb=""
find Transaction≥lasttime
if info("found")=0
stop
endif
loop
num=1
loop
stoploopif num=arraysize(Order,¶)+1
raya=str(Transaction)+¬+extract(Order,¶,num)+¬+datepattern(Date,"mm/dd/yy")
rayb=rayb+¶+raya
rayb=arraystrip(rayb,¶)
num=num+1
while forever
window "44ogswalkinsales:secret"
openfile "+@rayb"
window waswindow
rayb=""
downrecord
stoploopif info("eof")
until info("stopped")
num=1
loop
stoploopif num=arraysize(Order,¶)+1
raya=str(Transaction)+¬+extract(Order,¶,num)+¬+datepattern(Date,"mm/dd/yy")
rayb=rayb+¶+raya
rayb=arraystrip(rayb,¶)
num=num+1
while forever
window "44ogswalkinsales:secret"
openfile "+@rayb"
window waswindow
rayb=""
;lasttime=Transaction
goform "sales"
selectall
lastrecord
save
window "44ogswalkinsales"
field Item
select val(Item[1,4])>8000
removeunselected
save
stop
call "walkin ordered"

˛/ogssales/6ˇ˛searchnotes/†ˇfileglobal searchtext
gettext "Search Notes for", searchtext
find Notes contains searchtext˛/searchnotes/†ˇ˛(extras)ˇ˛/(extras)ˇ˛build_vertical_fileˇglobal order, neworder,firstorder, newseq, order_len
local allwindows, numwindows, n, onewindowname

;; go to the datasheet. If the datasheet is not currently open, 
;; go to the active window and switch it to the datasheet
gosheet

;; create a list of all of the currently open windows in the tally
allwindows = listwindows("Walkin Register44")

;; Since we just ran "gosheet," the datasheet will be the active
;; window, and will be the first one in the list of windows. We're
;; going to close all of the windows in this list, so before we start
;; that, we want to delete the datasheet from the list.

if arraysize(allwindows,¶) > 1
    allwindows = arraydelete(allwindows,1,1,¶)
    numwindows = arraysize(allwindows,¶)

    ;; loop through the list of windows (except for the datasheet)
    ;; and close them all
    n = 0
    loop
        onewindowname = array(allwindows,n+1,¶)
        window onewindowname
        closewindow
        n = n+1
        numwindows = numwindows - 1
        stoploopif numwindows = 0
    while forever

endif

waswindow=info("windowname")
 
openfile "44walkin_vertical_ogs"
removesummaries "7"
selectall
field TransactionNo
Sortup
lastrecord
newseq=TransactionNo

window waswindow
select  Transaction>newseq and Transfer notcontains "Y"
if info("empty")
    message "No new orders"
    stop
endif
Field Transaction
Sortup

firstrecord
firstorder=Transaction
window "44walkin_vertical_ogs"
if error 
    openfile "44walkin_vertical_ogs"
endif
window waswindow
neworder=""
order=""
firstrecord
loop
    order=Order
    order_len = arraysize(extract(order,¶,1),¬)
    
    case order_len = 7
        ArrayFilter order,neworder,¶,str(Transaction)+¬+str(Date)+¬+import()
    case order_len = 6
        ArrayFilter order,neworder,¶,str(Transaction)+¬+str(Date)+¬+""+¬+import()
    case order_len = 5
        ArrayFilter order,neworder,¶,str(Transaction)+¬+str(Date)+¬+""+¬+extract(import(),¬,1)+¬+extract(import(),¬,2)+¬+"0"+¬+extract(import(),¬,3)+¬+extract(import(),¬,4)+¬+extract(import(),¬,5)
    endcase
    
    window "44walkin_vertical_ogs:secret"
    openfile "+@neworder"
    window waswindow
    downrecord
    order=""
    neworder=""
until info("stopped")

window waswindow
selectall
window "44walkin_vertical_ogs"

call "get_IDs"

;;--------------------------------------------------------------------
;; ------ build transfers vertical file ------
;;--------------------------------------------------------------------

openfile "44transfers_vertical_ogs"
removesummaries "7"
selectall
field TransactionNo
Sortup
lastrecord
newseq=TransactionNo

window waswindow
select  Transaction>newseq and Transfer contains "Y"
Field Transaction
Sortup
if info("selected")=info("records")
    message "No new transfers"
    stop
endif

firstrecord
firstorder=Transaction
window "44transfers_vertical_ogs"
if error 
    openfile "44transfers_vertical_ogs"
endif
window waswindow
neworder=""
order=""
firstrecord
loop
    order=Order
    order_len = arraysize(extract(order,¶,1),¬)
    
    case order_len = 7
        ArrayFilter order,neworder,¶,str(Transaction)+¬+str(Date)+¬+import()
    case order_len = 6
        ArrayFilter order,neworder,¶,str(Transaction)+¬+str(Date)+¬+""+¬+import()
    case order_len = 5
        ArrayFilter order,neworder,¶,str(Transaction)+¬+str(Date)+¬+""+¬+extract(import(),¬,1)+¬+extract(import(),¬,2)+¬+"0"+¬+extract(import(),¬,3)+¬+extract(import(),¬,4)+¬+extract(import(),¬,5)
    endcase
    
    window "44transfers_vertical_ogs:secret"
    openfile "+@neworder"
    window waswindow
    downrecord
    order=""
    neworder=""
until info("stopped")

window waswindow
selectall
window "44transfers_vertical_ogs"

call "get_IDs"

message "Finished Walk-in build vertical file macro"˛/build_vertical_fileˇ˛checkcashboxˇlocal cash, dater
dater=""
cash=0
gosheet

gettext "What date?",dater
message dater
select Date>date(dater) and TransactionType="Cash"

if info("selected")=info("records")
goform "sales"
message "No Cash Today"
else
Field Paid
Total
lastrecord
cash=Paid
removesummaries 7
selectall
select Date>date(dater) and TransactionType="Mixed" and Cash>0

if info("selected")=info("records") 
goto donetime
else 
field Cash
Total
lastrecord
cash=cash+Cash
removesummaries 7
endif
endif
donetime:
selectall
lastrecord
goform "sales"
message "Cash Sales: "+pattern(cash,"$#,.##")

clipboard()=str(cash)˛/checkcashboxˇ˛receiptˇglobal waswindow
waswindow=info("formname")
;superobject "OGSEnter","Open","Clear"
printusingform "","receipt"
printonerecord dialog 
«SpareText4»="Receipt Printed"

GoForm waswindow
if Paid≤0 and Total>0 and PurchaseOrder="" and Notes notcontains "owes" and TransactionType notcontains "don" and TransactionType notcontains "PO" and TransactionType notcontains "transfer"
    Message "Please complete the sale"
    stop
    endif
˛/receiptˇ˛checkchecksˇlocal checkers, dater
dater=""
checkers=0
gosheet

gettext "What date?",dater
message dater
select Date>date(dater) and  TransactionType="Check"



if info("selected")=info("records")
goform "sales"
message "No Checks Today"
else
Field Paid
Total
lastrecord
checkers=Paid
removesummaries 7
selectall
select Date>date(dater) and TransactionType="Mixed" and Check>0

if info("selected")=info("records")
goto endtimes
else
field Check
Total
lastrecord
checkers=checkers+Check
removesummaries 7
endtimes:
selectall
lastrecord
goform "sales"
message "Check Sales: "+pattern(checkers,"$#,.##")
endif
endif
clipboard()=str(checkers)

˛/checkchecksˇ˛reconcileˇlocal credit, dater
dater=""
credit=0
gosheet
gettext "What date?",dater
message dater
select Date>date(dater) and TransactionType="CC"

Field Paid
Total
lastrecord
credit=Paid
removesummaries 7
selectall
select Date>date(dater) and TransactionType="Mixed" and CreditCard>0



if info("selected")=info("records")
goto enditall
else
field CreditCard
Total
lastrecord
credit=credit+CreditCard
removesummaries 7
endif
enditall:
selectall
lastrecord
goform "sales"
message "Credit Card Sales: "+pattern(credit,"$#,.##")
clipboard()=str(credit)˛/reconcileˇ˛.monthlytotalˇsynchronize
local totes,lastyear,diff
select monthvalue(Date)=monthvalue(today()) and TransactionType notcontains "don" and TransactionType notcontains "transfer"
field Adjtotal
Total
lastrecord
totes=Adjtotal
openfile "Walkin Register43.unlinked"
select monthvalue(Date)=monthvalue(today()-365) and Date≤today()-365 and TransactionType notcontains "don" and TransactionType notcontains "transfer"
field Adjtotal
Total
lastrecord
lastyear=Adjtotal
diff=divzero(totes,lastyear)-1
window "Walkin Register44:sales"
message "Sales So Far This Month "+pattern(totes,"$#,.##")+¶+"So Far This Month Last Year "+pattern(lastyear,"$#,.##")+¶+?(diff≥0,"Up ","Down ")+str(diff*100)+"%"
removeallsummaries
selectall
lastrecord˛/.monthlytotalˇ˛.ytdtotalˇsynchronize
local totes,lastyear,diff
select TransactionType notcontains "don" and TransactionType notcontains "transfer"
field Adjtotal
Total
lastrecord
totes=Adjtotal
openfile "Walkin Register43.unlinked"
select Date≤today()-365 and TransactionType notcontains "don" and TransactionType notcontains "transfer"
field Adjtotal
Total
lastrecord
lastyear=Adjtotal
removeallsummaries
selectall
diff=divzero(totes,lastyear)-1
window "Walkin Register44:sales"
message "Sales So Far This Year "+pattern(totes,"$#,.##")+¶+"So Far Last Year "+pattern(lastyear,"$#,.##")+¶+?(diff≥0,"Up ","Down ")+str(diff*100)+"%"
removeallsummaries
selectall
lastrecord˛/.ytdtotalˇ˛.dailyˇsynchronize
local totes
select Date=today() and TransactionType notcontains "don" and TransactionType notcontains "transfer"
field Adjtotal
Total
lastrecord
totes=pattern(Adjtotal,"$#,.##")
message "Today's sales: "+totes
removesummaries 7
selectall
lastrecord˛/.dailyˇ˛.transferˇif Transfer="Y"
TransactionType="Transfer"
TaxExempt="Y"
loop
getscrapok "Which Division?"
repeatloopif clipboard()="" or (clipboard() notcontains "seeds" and clipboard() notcontains "trees" and clipboard() notcontains "bulbs")
stoploopif clipboard()≠""
while forever
Name=upperword(clipboard())
Notes="Transfer to "+Name
call .entry
Else TransactionType=""
TaxExempt="N"
Notes=""
Name=""
endif


˛/.transferˇ˛.deleterecordˇyesno "Clear out this transaction?"
if clipboard() contains "yes"
    ;clear record leaving no ghost record
    Order=""
    TaxTotal=0
    Subtotal=0
    Adjtotal=0
    MemberDiscount=0
    Total=0
    Discount=0
    «$Shipping»=0
    SalesTax=0
    Paid=0
    Cash=0
    Check=0
    CreditCard=0
    Gift_Certificate=0
    TransactionType=""
    C#=0
    Group=""
    Name=""
    Notes="VOIDED TRANSACTION"
    SeedSales=0
    TreeSales=0
    OGSSales=0
    MooseSales=0
    BulbsSales=0
    BalanceDue=0
    enter=""
    deleterecord
else 
    stop
endif˛/.deleterecordˇ˛find customers without c#ˇselect «C#» = 0 and Name <> "" and  (Staff = "Y" or Special = "Y" or TaxExempt = "Y" or «%Discount» > 0) and Group notcontains "Arbico"
˛/find customers without c#ˇ˛SourceGetˇlocal Dictionary, ProcedureList
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
message ProcedureList //messages which procedures got changed˛/SourceGetˇ