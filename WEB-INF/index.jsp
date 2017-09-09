
<%
session.invalidate();
response.sendRedirect(request.getContextPath() + "/login.html");
%>
