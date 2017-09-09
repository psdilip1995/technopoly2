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
	 if(fn.equals("getUserName")){
		 //con.close();
		 out.print(session.getAttribute("username"));
	 }
	 if(fn.equals("getCurrentRound")){
		 rs=stmt.executeQuery("select * from admin_info where userid='"+session.getAttribute("userid")+"'");
		 rs.next();
		 out.print(rs.getString("currentround"));
		 con.close();
	 }
	 if(fn.equals("changeRound")){
		 String round=request.getParameter("round");
		 stmt.executeUpdate("update admin_info set currentround='"+round+"' where userid='"+session.getAttribute("userid")+"'");
		 out.print(round);
		 con.close();
	 }
	 if(fn.equals("getGameStatus")){
		 rs=stmt.executeQuery("select * from admin_info where userid='"+session.getAttribute("userid")+"'");
		 rs.next();
		 out.print(rs.getString("gamestatus"));
		 con.close();
	 }
	 if(fn.equals("changeGameStatus")){
		 String gamestatus=request.getParameter("gameStatus");
		 stmt.executeUpdate("update admin_info set gamestatus='"+gamestatus+"' where userid='"+session.getAttribute("userid")+"'");
		 out.print(gamestatus);
		 con.close();
	 }
	 if(fn.equals("createUsers")){
		 int users=Integer.parseInt(request.getParameter("users"));
		 rs=stmt.executeQuery("select college,maxusers from admin_info where userid='"+session.getAttribute("userid")+"'");
		 rs.next();
		 String college=rs.getString("college");
		 int maxusers=Integer.parseInt(rs.getString("maxusers"));
		 rs=stmt.executeQuery("select count(*) from user_info where quota='"+college+"'");
		 rs.next();
		 int currentUserCount=Integer.parseInt(rs.getString(1));
		 if(maxusers-currentUserCount < users)
			 out.print("you can create only "+(maxusers-currentUserCount)+" users now. If you want to create more users contact administrator!");
		 else
		 {
			 rs=stmt.executeQuery("select auto_increment from information_schema.tables where table_schema = 'technopoly2' and table_name = 'user_info' ");
			 rs.next();
			 int teamname=Integer.parseInt(rs.getString(1));
			 for(int i=0;i<users;i++)
				 stmt.executeUpdate("insert into user_info values(null,null,'password',null,null,null,'"+(teamname++)+"','active','"+college+"',null,5000)");
			 out.print("created "+users+" users!");
		 }
		 con.close();
	 }
	 if(fn.equals("getStats")){
		 rs=stmt.executeQuery("select college,maxusers from admin_info where userid='"+session.getAttribute("userid")+"'");
		 rs.next();
		 String college=rs.getString("college");
		 String maxusers=rs.getString("maxusers");
		 rs=stmt.executeQuery("select count(*) from user_info where quota='"+college+"'");
		 rs.next();
		 String createdUsers=rs.getString(1);
		 rs=stmt.executeQuery("select count(*) from user_info where quota='"+college+"' and username is not null");
		 rs.next();
		 String registeredUsers=rs.getString(1);
		 rs=stmt.executeQuery("select count(*) from user_info where quota='"+college+"' and status='active' and username is not null");
		 rs.next();
		 String activeUsers=rs.getString(1);
		 int inactiveUsers=Integer.parseInt(registeredUsers)-Integer.parseInt(activeUsers);
		 int freeusers=Integer.parseInt(createdUsers)-Integer.parseInt(registeredUsers);
		 out.print("maximum users : "+maxusers+"<br>");
		 out.print("created users &nbsp&nbsp&nbsp&nbsp: "+createdUsers+"<br>");
		 out.print("registered users : "+registeredUsers+"<br>");
		 out.print("&nbsp&nbsp&nbsp&nbspactive &nbsp&nbsp: "+activeUsers+"<br>");
		 out.print("&nbsp&nbsp&nbsp&nbspinactive : "+inactiveUsers+"<br>");
		 out.print("free users : "+freeusers+"<br>");
		 con.close();
	 }
	 if(fn.equals("getUserDetails")){
		 String status=request.getParameter("status");
		 rs=stmt.executeQuery("select college from admin_info where userid='"+session.getAttribute("userid")+"'");
		 rs.next();
		 String college=rs.getString("college");
		 if(status.equals("active")){
			rs=stmt.executeQuery("select * from user_info where quota='"+college+"' and status='active' and username is not null");
			out.print("Active Users<br><table style='width:100%;border-collapse:collapse' border=1><tr><th>User id</th><th>username</th><th>email</th><th>college</th><th>teamname</th><th>ph no.</th><th>deactive</th></tr>");
			while(rs.next()){
				String uid=rs.getString("userid");
				out.print("<tr id='activeuser"+uid+"'><td>"+uid+"</td><td>"+rs.getString("username")+"</td><td>"+rs.getString("email")+"</td><td>"+rs.getString("college")+"</td><td>"+rs.getString("teamname")+"</td><td>"+rs.getString("phone")+"</td><td><button onclick='makeUserInactive("+uid+")'>X</button></td></tr>");
			}
			con.close();
			out.print("</table>"); 
		 }
		 if(status.equals("inactive")){
			rs=stmt.executeQuery("select * from user_info where quota='"+college+"' and status='inactive'");
			out.print("Inactive Users<br><table style='width:100%;border-collapse:collapse' border=1><tr><th>User id</th><th>username</th><th>email</th><th>college</th><th>teamname</th><th>ph no.</th><th>Activate</th></tr>");
			while(rs.next()){
				String uid=rs.getString("userid");
				out.print("<tr id='inactiveuser"+uid+"'><td>"+uid+"</td><td>"+rs.getString("username")+"</td><td>"+rs.getString("email")+"</td><td>"+rs.getString("college")+"</td><td>"+rs.getString("teamname")+"</td><td>"+rs.getString("phone")+"</td><td><button onclick='makeUserActive("+uid+")'>A</button></td></tr>");
			}
			con.close();
			out.print("</table>");
		 }
		 if(status.equals("freeusers")){
			rs=stmt.executeQuery("select * from user_info where quota='"+college+"' and username is null");
			out.print("Available Accounts <br><table style='width:100%;border-collapse:collapse' border=1><tr><th>User ID</th><th>Password</th></tr>");
			while(rs.next())
				out.print("<tr><td>"+rs.getString("userid")+"</td><td>"+rs.getString("password")+"</td></tr>");
			out.print("</table>");
			con.close();
		 }
	 }
	 if(fn.equals("makeUserActive")){
		 String userid=request.getParameter("userid");
		 stmt.executeUpdate("update user_info set status='active' where userid="+userid+" ");
		 out.print("user with userid "+userid+" made Active!");
		 con.close();
	 }
	 if(fn.equals("makeUserInactive")){
		 String userid=request.getParameter("userid");
		 stmt.executeUpdate("update user_info set status='inactive' where userid="+userid+" ");
		 out.print("user with userid "+userid+" made Inactive!");
		 con.close();
	 }
	 if(fn.equals("manageUsers")){
		 String fun=request.getParameter("fun");
		 int condition=Integer.parseInt(request.getParameter("condition"));
		 rs=stmt.executeQuery("select college from admin_info where userid='"+session.getAttribute("userid")+"'");
		 rs.next();
		 String college=rs.getString("college");
		 if(fun.equals("activateAll")){
			 stmt.executeUpdate("update user_info set status='active' where quota='"+college+"' and username is not null");
			 out.print("All users are made active!");
		 }
		 if(fun.equals("deactivateAll")){
			 stmt.executeUpdate("update user_info set status='inactive' where quota='"+college+"' and username is not null");
			 out.print("All users are made inactive!");
		 }
		 if(fun.equals("activate")){
			 stmt.executeUpdate("update user_info set status='active' where quota='"+college+"' and balance >= "+condition+" and username is not null");
			 out.print("users with balance greater than or equal to "+condition+" are activated!");
		 }
		 if(fun.equals("getUserCount")){
			 rs=stmt.executeQuery("select count(*) from user_info where quota='"+college+"' and balance >= "+condition+" and username is not null");
			 rs.next();
			 out.print(rs.getString(1)+" users are having balance more than or equal to "+condition);
		 }
		 if(fun.equals("get")){
			 rs=stmt.executeQuery("select * from user_info where userid='"+condition+"' and quota='"+college+"'");
			 if(rs.next()){
				 out.print("<table style='width:100%;border-collapse:collapse' border=1><tr><th>Field</th><th>Value</th></tr>");
				 out.print("<tr><td>User ID </td><td><input style='background-color:lightgrey' type='text' value='"+rs.getString("userid")+"' id='useruserid' readonly/></td></tr>");
				 out.print("<tr><td>Username</td><td>"+rs.getString("username")+"</td></tr>");
				 out.print("<tr><td>Phone number</td><td><input type='text' value='"+rs.getString("phone")+"' id='userphone'/></td></tr>");
				 out.print("<tr><td>Password</td><td><input type='button' value='reset to password123' onclick='resetUserPassword()'/></td></tr>");
				 out.print("<tr><td>email</td><td><input type='text' value='"+rs.getString("email")+"' id='useremail'/></td></tr>");
				 out.print("<tr><td>college</td><td>"+rs.getString("college")+"</td></tr>");
				 out.print("<tr><td>team name</td><td>"+rs.getString("teamname")+"</td></tr>");
				 out.print("<tr><td>status</td><td><input type='text' value='"+rs.getString("status")+"' id='useruserstatus' readonly/><input type='button' value='Flip' onclick='flipUserStatus()'/></td></tr>");
				 out.print("<tr><td>balance</td><td><input type='text' value='"+rs.getString("balance")+"' id='userbalance'/></td></tr></table>");
				 out.print("<input type='button' value='update user' onclick='updateSingleUser()'/>");
			 }
			 else
				 out.print("no user exist with userid = "+condition);
		 }
		 con.close();
	 }
	 if(fn.equals("resetUserPassword")){
		 rs=stmt.executeQuery("select college from admin_info where userid='"+session.getAttribute("userid")+"'");
		 rs.next();
		 String college=rs.getString("college");
		 String userid=request.getParameter("userid");
		 stmt.executeUpdate("update user_info set password='password123' where userid="+userid+" and quota='"+college+"'");
		 out.print("password is reset for user with userid "+userid);
		 con.close();
	 }
	 if(fn.equals("flipUserStatus")){
		 String userid=request.getParameter("userid");
		 String status=request.getParameter("status");
		 rs=stmt.executeQuery("select college from admin_info where userid='"+session.getAttribute("userid")+"'");
		 rs.next();
		 String college=rs.getString("college");
		 stmt.executeUpdate("update user_info set status='"+status+"' where userid="+userid+" and quota='"+college+"'");
		 out.print(status);
		 con.close();
	 }
	 if(fn.equals("updateSingleUser")){
		 rs=stmt.executeQuery("select college from admin_info where userid='"+session.getAttribute("userid")+"'");
		 rs.next();
		 String college=rs.getString("college");
		 String userid=request.getParameter("userid");
		 String phone=request.getParameter("phone");
		 String email=request.getParameter("email");
		 String balance=request.getParameter("balance");
		 stmt.executeUpdate("update user_info set phone='"+phone+"', email='"+email+"', balance="+balance+" where userid="+userid+" and quota='"+college+"'");
		 out.print("details for user with userid "+userid+" are updated");
		 con.close();
	 }
	 if(fn.equals("manageQ")){
		 String func=request.getParameter("func");
		 if(func.equals("insertForm")){
			 out.print("<b>Insert Questions</b><br>");
			 out.print("<input type='radio' value='violet' name='qtype' id='qt1' checked/>Violet");
			 out.print("<input type='radio' value='blue' name='qtype' id='qt2' />Blue");
			 out.print("<input type='radio' value='red' name='qtype' id='qt3' />Red");
			 out.print("<input type='radio' value='gold' name='qtype' id='qt4' />Gold<br>");
			 out.print("<textarea cols='80' rows='20' id='question'></textarea><br>");
			 out.print("A. <textarea rows='5' cols='10' id='optionA' style='margin: 0px; width: 257px; height: 124px;'></textarea>");
			 out.print("B. <textarea rows='5' cols='10' id='optionB' style='margin: 0px; width: 257px; height: 124px;'></textarea><br>");
			 out.print("C. <textarea rows='5' cols='10' id='optionC' style='margin: 0px; width: 257px; height: 124px;'></textarea>");
			 out.print("D. <textarea rows='5' cols='10' id='optionD' style='margin: 0px; width: 257px; height: 124px;'></textarea><br>");
			 out.print("correct option <input type='text' id='correctAnswer'/><br>");
			 out.print("<input type='button' value='Insert Question' onclick=\"manageQ('insertQuestion','QuestionMessage')\"/>");
			 out.print("<div id='QuestionMessage'></div>");
		 }
		 if(func.equals("editForm")){
			 out.print("<b>Edit Questions</b><br>");
			 out.print("enter Question id <input type='text' id='getQuestionId'/><input type='button' value='get question' onclick=\"manageQ('getQuestion','QuestionMessage')\"/><br>");
			 out.print("Question Type <input type='text' value='' id='editQT' readonly/><br>");
			 out.print("<textarea cols='80' rows='20' id='question'></textarea><br>");
			 out.print("A. <textarea rows='5' cols='10' id='optionA' style='margin: 0px; width: 257px; height: 124px;'></textarea>");
			 out.print("B. <textarea rows='5' cols='10' id='optionB' style='margin: 0px; width: 257px; height: 124px;'></textarea><br>");
			 out.print("C. <textarea rows='5' cols='10' id='optionC' style='margin: 0px; width: 257px; height: 124px;'></textarea>");
			 out.print("D. <textarea rows='5' cols='10' id='optionD' style='margin: 0px; width: 257px; height: 124px;'></textarea><br>");
			 out.print("correct option <input type='text' id='correctAnswer'/><br>");
			 out.print("<input type='button' value='update Question' onclick=\"manageQ('updateQuestion','QuestionMessage')\"/>");
			 out.print("<div id='QuestionMessage'></div>");
		 }
		 if(func.equals("deleteForm")){
			 out.print("<b>Delete Questions</b><br>");
			 out.print("enter Question id <input type='text' id='getQuestionId'/><input type='button' value='get question' onclick=\"manageQ('getQuestion','QuestionMessage')\"/><br>");
			 out.print("Question Type <input type='text' value='' id='editQT' readonly/><br>");
			 out.print("<textarea cols='80' rows='20' id='question' readonly></textarea><br>");
			 out.print("A. <textarea rows='5' cols='10' id='optionA' style='margin: 0px; width: 257px; height: 124px;' readonly></textarea>");
			 out.print("B. <textarea rows='5' cols='10' id='optionB' style='margin: 0px; width: 257px; height: 124px;' readonly></textarea><br>");
			 out.print("C. <textarea rows='5' cols='10' id='optionC' style='margin: 0px; width: 257px; height: 124px;' readonly></textarea>");
			 out.print("D. <textarea rows='5' cols='10' id='optionD' style='margin: 0px; width: 257px; height: 124px;' readonly></textarea><br>");
			 out.print("correct option <input type='text' id='correctAnswer' readonly/><br>");
			 out.print("<input type='button' value='delete Question' onclick=\"manageQ('deleteQuestion','manageQuestionsForm')\"/>");
			 out.print("<div id='QuestionMessage'></div>");
		 }
		 if(func.equals("insertQuestion")){
			 out.print("inserting question");
			 String questionType=request.getParameter("insertQuestionType");
			 String question=request.getParameter("question");
		 }
		 if(func.equals("updateQuestion")){
			 out.print("updating question");
		 }
		 if(func.equals("deleteQuestion")){
			 out.print("deleting question");
		 }
		 con.close();
	 }
 }catch(Exception e){ con.close();%>Exception occured :<br> <%= e%><%}
%>