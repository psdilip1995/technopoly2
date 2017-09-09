<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page
import = "java.sql.*"
%>
<%!
 Statement stmt;
 Connection con;
 ResultSet rs;
%>
<%
try{
	 Class.forName("com.mysql.jdbc.Driver");
	 String dburl = System.getenv("OPENSHIFT_MYSQL_DB_URL");
	 String dbuname=System.getenv("OPENSHIFT_MYSQL_DB_USERNAME");
	 String dpass=System.getenv("OPENSHIFT_MYSQL_DB_PASSWORD");
	 String dhost=System.getenv("OPENSHIFT_MYSQL_DB_HOST");
	 String dport=System.getenv("OPENSHIFT_MYSQL_DB_PORT");
	 String url="jdbc:mysql://"+dhost+":"+dport+"/technopoly2";
	 con=DriverManager.getConnection(url,dbuname,dpass);
	 stmt = con.createStatement();
	 String fn=request.getParameter("function");
	 if(fn.equals("getOnlyUserName")){
		 out.print(session.getAttribute("username"));
	 }
	 if(fn.equals("getBalance")){
		 rs=stmt.executeQuery("select balance from user_info where userid='"+session.getAttribute("userid")+"'");
		 rs.next();
		 int balance1 = Integer.parseInt(rs.getString("balance"));
		 rs=stmt.executeQuery("select myanswer from user_"+session.getAttribute("userid")+" where qid='balance'");
		 rs.next();
		 int balance2 = Integer.parseInt(rs.getString("myanswer"));
		 if(balance1==balance2)
			 out.print(balance1);
		 else
			 out.print("error");
	 }
	 if(fn.equals("getQuestions")){
		 String type=request.getParameter("type");
		 String sql="";
		 if(type.equals("gold") || type.equals("red"))
		 sql="select * from "+session.getAttribute("quota")+"_questions where qid not in (select qid from user_"+session.getAttribute("userid")+") and type='"+type+"' and owner='bank'";
	     if(type.equals("violet") || type.equals("blue"))
		 sql="select * from "+session.getAttribute("quota")+"_questions where qid not in (select qid from user_"+session.getAttribute("userid")+") and type='"+type+"'";
		 rs=stmt.executeQuery(sql);
		 while(rs.next()){
			out.print("<button onclick=\"buyQuestion('"+rs.getString("qid")+"')\"><img alt='question' src='images/"+type+"-coin.png' style='width:60px;height:100px'></button>");
		 }
	 }
	 if(fn.equals("buyQuestionFromBank")){
		 String qid=request.getParameter("qid");
		 String qtype="";
		 int reqbal=0;
		 if(qid.charAt(0)=='R')
		 {
			 qtype="red";
			 reqbal=500;
		 }
		 else if(qid.charAt(0)=='G')
		 {
			 qtype="gold";
			 reqbal=1000;
		 }
		 else if(qid.charAt(0)=='V')
		 {
			 qtype="violet";
			 reqbal=100;
		 }
		 else if(qid.charAt(0)=='B')
		 {
			 qtype="blue";
			 reqbal=250;
		 }
		 rs=stmt.executeQuery("select gamestatus from admin_info where college='"+session.getAttribute("quota")+"'");
		 rs.next();
		 if(rs.getString("gamestatus").equals("ON")){
			 rs=stmt.executeQuery("select balance from user_info where userid="+session.getAttribute("userid"));
			 rs.next();
			 int bal=Integer.parseInt(rs.getString("balance"));
			 if(bal>=reqbal){
			 rs=stmt.executeQuery("select * from "+session.getAttribute("quota")+"_questions where qid='"+qid+"'");
			 if(rs.next()){
				 if(rs.getString("type").equals("red") || rs.getString("type").equals("gold")){
				 if(rs.getString("owner").equals("bank")){
					stmt.executeUpdate("update "+session.getAttribute("quota")+"_questions set owner='"+session.getAttribute("userid")+"' where qid='"+qid+"'");
					stmt.executeUpdate("insert into user_"+session.getAttribute("userid")+" values('"+qtype+"','"+qid+"',NULL,'no','"+session.getAttribute("userid")+"')");
					stmt.executeUpdate("insert into "+session.getAttribute("quota")+"_log values('"+session.getAttribute("userid")+"','BUY QUESTION FROM BANK','"+qid+"')");
					int leftbal=bal-reqbal;
					stmt.executeUpdate("update user_info set balance='"+leftbal+"' where userid="+session.getAttribute("userid"));
					stmt.executeUpdate("update user_"+session.getAttribute("userid")+" set myanswer='"+leftbal+"' where qid='balance'");
					out.print("you have purchased "+qid);
				 }
				 else
					 out.print("This question is just soldout! try again with other question");
				 }
				 else{
					stmt.executeUpdate("insert into user_"+session.getAttribute("userid")+" values('"+qtype+"','"+qid+"',NULL,'no','"+session.getAttribute("userid")+"')");
					stmt.executeUpdate("insert into "+session.getAttribute("quota")+"_log values('"+session.getAttribute("userid")+"','BUY QUESTION FROM BANK','"+qid+"')");
					int leftbal=bal-reqbal;
					stmt.executeUpdate("update user_info set balance='"+leftbal+"' where userid="+session.getAttribute("userid"));
					stmt.executeUpdate("update user_"+session.getAttribute("userid")+" set myanswer='"+leftbal+"' where qid='balance'");
					out.print("you have purchased "+qid);
				 }
			 }
			 }
			 else
				 out.print("you do not have enough balance!<script>getBalance();</script>");
		 }else{
			 out.print("Game is stopped my admin! you can not perform any actions now! Please Logout");
		 }
	 }
	 if(fn.equals("sellQuestion")){
		 String qid=request.getParameter("qid");
		 String price=request.getParameter("price");
		 String qtype="";
		 if(qid.charAt(0)=='R'){
			 qtype="red";
		 }else if(qid.charAt(0)=='G'){
			 qtype="gold";
		 }
		 rs=stmt.executeQuery("select * from user_"+session.getAttribute("userid")+" where qid='"+qid+"' and owner='"+session.getAttribute("userid")+"' and market='no' and myanswer is null");
		 if(rs.next()){
			stmt.executeUpdate("update "+session.getAttribute("quota")+"_questions set market='yes' , owner='market' where qid='"+qid+"' and owner='"+session.getAttribute("userid")+"'");
			stmt.executeUpdate("update user_"+session.getAttribute("userid")+" set market='yes' , owner='market' where qid='"+qid+"'");
			stmt.executeUpdate("insert into "+session.getAttribute("quota")+"_market values('"+qtype+"','"+qid+"','"+session.getAttribute("userid")+"',NULL,'"+price+"')");
			stmt.executeUpdate("insert into "+session.getAttribute("quota")+"_log values('"+session.getAttribute("userid")+"','SOLD IN MARKET','"+qid+"')");
			out.print("you sold the question in market successfully");
		 }
		 else
			 out.print("you are not the owner of the question or you have already sold the question in market or you have already solved the question");
	 }
	 if(fn.equals("displaySoldQuestionsInMarket")){
		 rs=stmt.executeQuery("select u.qid,cm.buyer,cm.price from user_"+session.getAttribute("userid")+" u inner join "+session.getAttribute("quota")+"_market cm where u.qid = cm.qid and cm.seller='"+session.getAttribute("userid")+"'");
		 if(rs.next()){
			 out.print("<table style='width:100%;border-collapse:collapse' border=1><tr><th>Question id</th><th>Bought By</th><th>P r i c e</th></tr>");
			 out.print("<tr><td>"+rs.getString("qid")+"</td><td>"+rs.getString("buyer")+"</td><td>"+rs.getString("price")+"</td></tr>");
			 while(rs.next())
				 out.print("<tr><td>"+rs.getString("qid")+"</td><td>"+rs.getString("buyer")+"</td><td>"+rs.getString("price")+"</td></tr>");
			 out.print("</table>");
		 }
		 else
			 out.print("you did not sold any questions yet");
	 }
	 if(fn.equals("displayQuestionsInMarketToBuy")){
		 rs=stmt.executeQuery("select * from "+session.getAttribute("quota")+"_market where seller !='"+session.getAttribute("userid")+"' and qid not in (select qid from user_"+session.getAttribute("userid")+") and buyer is null");
		 while(rs.next()){
			 String qtype="";
			 if(rs.getString("qid").charAt(0)=='G')
				 qtype="gold";
			 if(rs.getString("qid").charAt(0)=='R')
				 qtype="red";
			 out.print("<button onclick=\"buyQuestionFromMarket('"+rs.getString("qid")+":"+rs.getString("seller")+"')\"><img alt='question' src='images/"+qtype+"-coin.png' style='width:60px;height:100px'>"+rs.getString("price")+"</button>");
		 }
	 }
	 if(fn.equals("buyQuestionFromMarket")){
		 rs=stmt.executeQuery("select gamestatus from admin_info where college='"+session.getAttribute("quota")+"'");
		 rs.next();
		 if(rs.getString("gamestatus").equals("ON")){
		 String qdetails=request.getParameter("question");
		 String[] details=qdetails.split(":");
		 String qid=details[0];
		 String qtype="";
		 if(qid.charAt(0)=='G')
			 qtype="gold";
		 else if(qid.charAt(0)=='R')
			 qtype="red";
		 String seller = details[1];
		 rs=stmt.executeQuery("select balance from user_info where userid="+seller);
		 rs.next();
		 int sellerbalance=Integer.parseInt(rs.getString("balance"));
		 rs=stmt.executeQuery("select balance from user_info where userid="+session.getAttribute("userid"));
		 rs.next();
		 int bal=Integer.parseInt(rs.getString("balance"));
		 rs=stmt.executeQuery("select * from "+session.getAttribute("quota")+"_market where qid='"+qid+"' and buyer is null");
		 if(rs.next()){
			 int price=Integer.parseInt(rs.getString("price"));
			 if(bal>=price){
				int rembal=bal-price;
				int sellernewbalance=sellerbalance+price;
				stmt.executeUpdate("update "+session.getAttribute("quota")+"_market set buyer='"+session.getAttribute("userid")+"' where qid='"+qid+"' and seller='"+seller+"'"); 
				stmt.executeUpdate("update user_"+seller+" set owner='"+session.getAttribute("userid")+"' where qid='"+qid+"'");
				stmt.executeUpdate("update "+session.getAttribute("quota")+"_questions set owner='"+session.getAttribute("userid")+"' , market='no' where qid='"+qid+"'");
				stmt.executeUpdate("insert into user_"+session.getAttribute("userid")+" values('"+qtype+"','"+qid+"',NULL,'no','"+session.getAttribute("userid")+"')");
				stmt.executeUpdate("insert into "+session.getAttribute("quota")+"_log values('"+session.getAttribute("userid")+"','BOUGHT QUESTION FROM MARKET FOR "+price+"','"+qid+"')");
				
				stmt.executeUpdate("update user_info set balance='"+rembal+"' where userid="+session.getAttribute("userid"));
				stmt.executeUpdate("update user_"+session.getAttribute("userid")+" set myanswer='"+rembal+"' where qid='balance'");
				stmt.executeUpdate("update user_info set balance='"+sellernewbalance+"' where userid="+seller);
				stmt.executeUpdate("update user_"+seller+" set myanswer='"+sellernewbalance+"' where qid='balance'");
				out.print("You have made a purchase and bought question "+qid+" from market!");
			 }
			 else
				 out.print("You do not have enough balance");
		 }
		 else
			 out.print("You just missed the question! Some one just bought it! Try with other question.<br><br>H U R R Y   U P !");
	 }
	 else
		 out.print("Game is stopped by admin! you can not perform any action now! Please LOGOUT");
	 }
	 if(fn.equals("displayQuestionsToSolve")){
		 rs=stmt.executeQuery("select * from user_"+session.getAttribute("userid")+" where market='no' and myanswer is null");
		 if(rs.next()){
			 out.print("<button onclick=\"solveQuestion('"+rs.getString("qid")+"')\"><img alt='question' src='images/"+rs.getString("type")+"-coin.png' style='width:60px;height:100px'></button>");
			 while(rs.next())
			 out.print("<button onclick=\"solveQuestion('"+rs.getString("qid")+"')\"><img alt='question' src='images/"+rs.getString("type")+"-coin.png' style='width:60px;height:100px'></button>");
		 }
		 else
			 out.print("you do not have any questions to solve, Purchase from bank or market and solve it here!");
	 }
	 if(fn.equals("displaylog")){
		 rs=stmt.executeQuery("select * from "+session.getAttribute("quota")+"_log where userid='"+session.getAttribute("userid")+"'");
		 out.print("<table style='width:100%'><tr><th>ACTION</th><th>QID</th></tr>");
		 while(rs.next()){
			 out.print("<tr><td>"+rs.getString("action")+"</td><td>"+rs.getString("qid")+"</td></tr>");
		 }
		 out.print("</table>");
	 }
	 if(fn.equals("displayquestion")){
		 String qid=request.getParameter("question");
		 rs=stmt.executeQuery("select * from "+session.getAttribute("quota")+"_questions cq inner join user_"+session.getAttribute("userid")+" u where cq.qid=u.qid and u.qid='"+qid+"' and u.market='no' and u.owner='"+session.getAttribute("userid")+"' and u.myanswer is null");
		 if(rs.next()){
			 out.print("Question Id : "+qid+"<br><br>"+rs.getString("question"));
		 }
		 else
			 out.print("This question is not eligible for solving!");
	 }
	 if(fn.equals("displayoption")){
		 String qid=request.getParameter("question");
		 String opt=request.getParameter("option");
		 rs=stmt.executeQuery("select * from "+session.getAttribute("quota")+"_questions cq inner join user_"+session.getAttribute("userid")+" u where cq.qid=u.qid and u.qid='"+qid+"' and u.market='no' and u.owner='"+session.getAttribute("userid")+"' and u.myanswer is null");
		 if(rs.next()){
			 out.print("<input type='checkbox' value='"+opt+"' id='option"+opt+"'/> "+opt+")<br>"+rs.getString("option"+opt));
		 }
		 else
			 out.print("This question is not eligible for solving!");
	 }
	 con.close();
 }catch(Exception e){ con.close();%>Exception occured :<br> <%= e%><%}
%>