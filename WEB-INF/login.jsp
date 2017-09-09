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
<title>TECHNOPOLY</title>
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
	 String userid=request.getParameter("userid");
	 String password=request.getParameter("password");
	 String regex="[0-9]+";
	 if(userid.matches(regex)){
		 /*user-login*/
		 rs=stmt.executeQuery("select * from user_info where userid="+userid);
		 if(rs.next()){
			 if(password.equals(rs.getString("password"))){
				if(rs.getString("status").equals("active")){
					session.setAttribute("userid",userid);
					session.setAttribute("username",rs.getString("username"));
					session.setAttribute("quota",rs.getString("quota"));
					if(password.equals("password")){
						response.setStatus(response.SC_MOVED_TEMPORARILY);
						response.setHeader("Location","firsttimelogin.html");
					}
					else if(password.equals("password123")){
						response.setStatus(response.SC_MOVED_TEMPORARILY);
						response.setHeader("Location","changepassword.html"); 
					}
					else{
						response.setStatus(response.SC_MOVED_TEMPORARILY);
						response.setHeader("Location","validateuser.html"); 
					}
				}else{
					response.setStatus(response.SC_MOVED_TEMPORARILY);
					response.setHeader("Location","displaymessageforuserstatus.html"); 
				}
			 }
			 else{
				 con.close();
				response.setStatus(response.SC_MOVED_TEMPORARILY);
				response.setHeader("Location","login.html"); 
			 }
		 }
		 else{
			 con.close();
			 response.setStatus(response.SC_MOVED_TEMPORARILY);
			 response.setHeader("Location","login.html");
		 }
		 /*end of user login logic */
	 }
	 else{
		 /*admin-login*/
		 rs=stmt.executeQuery("select * from admin_info where userid='"+userid+"'");
		 if(rs.next()){
			 if(password.equals(rs.getString("password"))){
				session.setAttribute("userid",userid);
				session.setAttribute("username",rs.getString("username"));
				session.setAttribute("userstatus",rs.getString("status"));
				con.close();
				if(session.getAttribute("userstatus").equals("active")){
				response.setStatus(response.SC_MOVED_TEMPORARILY);
				response.setHeader("Location","adminhome.html"); 
				}else{
					response.setStatus(response.SC_MOVED_TEMPORARILY);
					response.setHeader("Location","displaymessageforuserstatus.html"); 
				}
			 }
			 else{
				 con.close();
				response.setStatus(response.SC_MOVED_TEMPORARILY);
				response.setHeader("Location","login.html"); 
			 }
		 }
		 else{
			 con.close();
			 response.setStatus(response.SC_MOVED_TEMPORARILY);
			 response.setHeader("Location","login.html");
		 }
	 }
 }catch(Exception e){ con.close();%>Exception occured :<br> <%= e%><%}


%>
</body>
</html>
