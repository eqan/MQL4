//+------------------------------------------------------------------+
//|                                                       martin.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


extern int distance=30;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   MathSrand(LocalTime());
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

int err = 0;
double Lot = 0.1;
double Ballance=0.0;
int start()
  {
//----
   if(OrdersTotal()==0&&err==0)
     {
      if(Ballance!=0.0)
        {
         if(Ballance>AccountBalance())
            Lot=2*Lot;
         else
            Lot=0.1;
        }
      Ballance=AccountBalance();

      int order;
      if(MathRand()%2==0)
         order=OrderSend(Symbol(),OP_BUY,Lot,Ask,5*Point,Bid-distance*Point,Ask+distance*Point);
      else
         order=OrderSend(Symbol(),OP_SELL,Lot,Bid,5*Point,Ask+distance*Point,Bid-distance*Point);

      if(order<0)
        {
         if(GetLastError()==134)
           {
            err=1;
            Print("NOT ENOGUGHT MONEY!!");
           }
         return (-1);
        }
      //n++;

     }


//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
