<?php 
    include("../api/dbclass.php");
    $db = new db_class();
    
    if($_REQUEST['submit'])
    {
         $where = "md5(email)='". $_REQUEST['id'] ."'";  
         $pass = sha1($_REQUEST['pass']);
         $query = "Update `user` set `password`='$pass'  where " .$where;
         $data = $db->db_query($query); 
         
         echo "Your new password has been set. Please login to tymepass with your new password.";
         exit;
    }
    else
    {
    $where = "md5(email)='". $_REQUEST['id'] ."'";
    $data = $db->db_select("user", "email, serverId", $where);
    if(empty($data))
    {
        echo "Link expired";    
        exit;
    }
?>
<script type="text/javascript">

    function foem_validate()
    {
        if(document.getElementById("pass")=="")
        {
            
            alert("Please enter Password");
            return false;
        }   
        else if(document.getElementById("pass") ==document.getElementById("cpass")) 
        {
            alert("Password not match");
             return false;
        }
        return true;
    }


</script>

<form action="" method="post" onsubmit="return foem_validate();">

    <table>
        <tr>
            <td>  Enter New Password </td>
            <td><input type="text" value="" name="pass" id="pass"></td>
        </tr>
     <!--   
        <tr>
            <td>Re-Enter New Password</td>
            <td><input type="text" value="" name="cpasss" id="cpasss"></td>
        </tr>
                -->
        <tr>
            <td colspan="2" align="center">
                <input type="submit" name="submit" value="Change Password" />
            </td>
            
        </tr>
    </table>

</form>


<?php } ?>
