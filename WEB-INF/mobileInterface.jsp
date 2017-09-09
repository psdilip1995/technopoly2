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
<html>
<head>
<title>TECHNOPOLY MOBILE INTERFACE</title>
</head>
<body>
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
	 String func=request.getParameter("function");
	 if(func.equals("getUserName")){
		 String userid=request.getParameter("userid");
		 rs=stmt.executeQuery("select username,mpin from user_info where userid="+userid+" and username is not null");
		 if(rs.next())
		 {
			 if(rs.getString(2)==null)
				out.print(rs.getString(1)+":no");
			 else
				out.print(rs.getString(1)+":yes"); 
		 }
		 else
			out.print("invalid user!:no");
	 }
	 if(func.equals("login")){
		 String userid=request.getParameter("userid");
		 String mpin=request.getParameter("mpin");
		 rs=stmt.executeQuery("select mpin from user_info where userid="+userid);
		 if(rs.next()){
			 if(mpin.equals(rs.getString(1)))
				 out.print("<input type='password' id='loginresult' value='success'/>");
			 else
				 out.print("<input type='password' id='loginresult' value='fail'/>");
				 /*out.print("SUCCESS");
			 else
				 out.print("<div style='text-align:center' onclick='verify2(\"Y\")'>WRONG MPIN! TRY AGAIN!<div>");*/
		 }
		 else
			 out.print("ERROR");
	 }
	 if(func.equals("setpin")){
		 String userid=request.getParameter("userid");
		 String password=request.getParameter("password");
		 String mpin=request.getParameter("mpin");
		 rs=stmt.executeQuery("select password from user_info where userid="+userid+" and mpin is null");
		 if(rs.next()){
			 if(password.equals(rs.getString(1))){
				 stmt.executeUpdate("update user_info set mpin='"+mpin+"' where userid="+userid);
				 out.print("<input type='hidden' value='success' id='result'/>");
			 }else{
				 out.print("<input type='hidden' value='wrong' id='result'/>");
			 }
		 }
		 else
			 out.print("<input type='hidden' value='already' id='result'/>");
	 }
	 if(func.equals("setTap")){
		 String userid=request.getParameter("userid");
		 String password=request.getParameter("password");
		 stmt.executeUpdate("update user_info set tappassword='"+password+"' where userid="+userid);
		 out.print("<div onclick=\"navigate('setpin2','onStart')\">BRILLIANT!<br>YOU ARE ALL SET!<br>YOU CAN LOGIN IN DIRECTLY BY TAPPING YOUR MOBILE SCREEN ON THE LOGIN PAGE<br><br>CLICK HERE TO LOGIN!</div>");
	 }
	 if(func.equals("getTapPassword")){
		 String userid=request.getParameter("userid");
		 rs=stmt.executeQuery("select tappassword from user_info where userid="+userid+" and tappassword is not null");
		 if(rs.next()){
			 out.print(":"+rs.getString(1)+":");
		 }else{
			 out.print(":0:0:0:0:0:0:0:0:");
		 }
	 }
	 if(func.equals("clearTest")){
		 stmt.executeUpdate("update user_info set mpin=null where userid = 12");
	 }
	 con.close();
 }catch(Exception e){ con.close();%>Exception occured :<br> <%= e%><%}
%>
</body>
</html>
