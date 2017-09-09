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
	 if(fn.equals("getUserId")){
		 out.print("<p>User Id : "+session.getAttribute("userid")+"</p>");
	 }
	 if(fn.equals("submitRegistration")){
		 String username=request.getParameter("username");
		 String password=request.getParameter("password");
		 String email=request.getParameter("email");
		 String phone=request.getParameter("phone");
		 String college=request.getParameter("college");
		 String teamname=request.getParameter("teamname");
		 String refid=request.getParameter("refid");
		 rs=stmt.executeQuery("select * from user_info where quota='"+session.getAttribute("quota")+"' and teamname='"+teamname+"'");
		 if(rs.next()){
			 out.print("<p>Team name already exsist! Try other name</p>");
		 }else if(password.equals("password") || password.equals("password123")){
			 out.print("<p>Password can not be password or password123</p>");
		 }else{
			 stmt.executeUpdate("update user_info set username='"+username+"',password='"+password+"',email='"+email+"',phone='"+phone+"',college='"+college+"',teamname='"+teamname+"',refid='"+refid+"' where userid="+session.getAttribute("userid")+" and quota='"+session.getAttribute("quota")+"'");
			 stmt.executeUpdate("insert into "+session.getAttribute("quota")+"_ref values("+session.getAttribute("userid")+","+refid+",'no')");
			 stmt.executeUpdate("create table user_"+session.getAttribute("userid")+" (type varchar(10),qid varchar(10) primary key,myanswer varchar(10),market varchar(3),owner varchar(10))");
			 stmt.executeUpdate("insert into user_"+session.getAttribute("userid")+" values('balance','balance','5000','no','balance');");
			 rs=stmt.executeQuery("select * from user_info where userid="+session.getAttribute("userid")+" and quota='"+session.getAttribute("quota")+"'");
			 rs.next();
			 if(rs.getString("username").equals(username) && rs.getString("teamname").equals(teamname))
				 out.print("<p>Details updated! <a href='index.jsp'>click here to login</a></p>");
			 else
				 out.print("<p>Something happened! contact Admin</p>");
		 }
	 }
	 if(fn.equals("submitResetPassword")){
		 String newPassword=request.getParameter("password");
		 if(newPassword.equals("password") || newPassword.equals("password123")){
			 out.print("<p>Password can not be password or password123!</p>");
		 }else{
		 stmt.executeUpdate("update user_info set password='"+newPassword+"' where quota='"+session.getAttribute("quota")+"' and userid="+session.getAttribute("userid"));
		 rs=stmt.executeQuery("select * from user_info where userid="+session.getAttribute("userid"));
		 rs.next();
		 if(rs.getString("password").equals(newPassword))
			 out.print("<p>Password Reset Done!</p><a href='index.jsp'>click here to login</a>");
		 else
			 out.print("<p>something happened!contact Admin</p>");
		 }
	 }
	 if(fn.equals("getUserName")){
		 out.print("<p>User Name : "+session.getAttribute("username")+"</p>");
	 }
	 if(fn.equals("getRoundDetails")){
		 rs=stmt.executeQuery("select gamestatus,currentround from admin_info where college='"+session.getAttribute("quota")+"'");
		 rs.next();
		 String round=rs.getString("currentround");
		 String gamestatus=rs.getString("gamestatus");
		 String temp="";
		 String href="";
		 if(round.equals("one"))
			 href="round1.html";
		 else
			 href="round2.html";
		 if(gamestatus.equals("ON"))
			 temp="<a href='"+href+"' style='text-decoration:none'>Start</a>";
		 else
			 temp=" and "+gamestatus;
		 out.print("current round is "+round+"<br>"+temp);
	 }
	 con.close();
 }catch(Exception e){ con.close();%>Exception occured :<br> <%= e%><%}
%>