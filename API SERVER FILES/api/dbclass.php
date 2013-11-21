<?php 

class db_class
{
    var $con = "";
    var $db = "";
var $siteurl="http://api.tymepass.com/";
    function db_class()
    {
       
        $this->con = mysql_connect("localhost", "tymepass_userr" , "}v88&G!uZ^{M");
        $this->db = mysql_selectdb("tymepass_thedb");
        
    }
    function test()
    {
         $res = mysql_query("SELECT MAX(iId) as iId FROM user");
         return mysql_fetch_assoc($res);
    }
    function db_insert($table){ 
    $q = mysql_query("DESCRIBE $table");
    $fields = "";
    $value = "";
    $pk = "";
    while($row = mysql_fetch_array($q)) {
        if ($row['Field']=='dDate')
        {
           if($fields=="")
           {
               $fields = $row['Field'];  
               $value = "'" . date('Y-m-d') . "'";  
           }
           else
           {
                 $fields .= "," . $row['Field'];  
                 $value .= ",'" . date("Y-m-d") . "'";
           } 
        }
        if($row[5] != "auto_increment")
        {
           // print_r($row);    
           if($fields=="")
           {
               $fields = "`" .$row['Field'] ."`";  
               $value = "'" . addslashes(@$_REQUEST[$row['Field']]) . "'";  
           }
           else
           {
                 $fields .= ",`" .$row['Field'] ."`";
                 $value .= ",'" . addslashes(@$_REQUEST[$row['Field']]) . "'";
           }
         }
         else
         {   
             $pk = $row['Field'];
         }
    }
    $query = "INSERT INTO ".$table.  "($fields) values ($value) ;"; 
    $result = mysql_query($query) ;
    if($result) 
    {
            $res['id'] =  (string)mysql_insert_id() ;
            return $res; 
        //return mysql_fetch_assoc($res);
        
    }
    else
    {
        $error[] = mysql_error();
        return $error;    
    }
     
} 
//END db_insert 




//////////////////////////////////////////////////////////// 
// Function Name:    db_update() 
//    This function takes all of the posted form elements  
//    and updates $table WHERE $pk = $pkval with new values. 
/////////////////////////////////////////////////////////// 
function db_update($table , $no_update = array()){ 
    $q = mysql_query("DESCRIBE $table");
    $fields = "";
    $no_update[] = 'dDate';  
    $no_update[] = 'UserId';  
    $pk=1;
    $pkval =2;
    while($row = mysql_fetch_array($q)) {
         
            if($row[5] != "auto_increment")
            {
                if(!in_array($row['Field'], $no_update))
                {
                       if($fields=="")
                       {
                           $fields = $row['Field'] . "='" . addslashes(@$_REQUEST[$row['Field']]) . "'";  
                       }
                       else
                       {
                             $fields .= ", " .$row['Field'] . "='" . addslashes(@$_REQUEST[$row['Field']]) . "'";  
                       }
                }
        }
        else
        {
            $pk =  $row['Field'];
            $pkval = @$_REQUEST[$row['Field']];
        }
    }
    
    
        $query = "UPDATE $table SET " . $fields . " where $pk='$pkval'"; 
        
    if($result = mysql_query($query)) 
    {
        $data["Suucess"] = "Data Update Successfully";
         return $data;
    }
    else
    {
        echo(mysql_error());    
    }
    
    
   
} 


function db_updatespecial($table , $no_update = array()){ 
    $q = mysql_query("DESCRIBE $table");
    $fields = "";
    $no_update[] = 'dDate';  
    $no_update[] = 'UserId';  
    $pk=1;
    $pkval =2;
    while($row = mysql_fetch_array($q)) {
         
            if($row[5] != "auto_increment")
            {
                if(!in_array($row['Field'], $no_update))
                {
                       if($fields=="")
                       {
                           $fields = $row['Field'] . "='" . addslashes(@$_REQUEST[$row['Field']]). "'";  
                       }
                       else
                       {
                             $fields .= ", " .$row['Field'] . "='" . addslashes(@$_REQUEST[$row['Field']]) . "'";  
                       }
                }
        }
        else
        {
            $pk =  $row['Field'];
            $pkval = @$_REQUEST[$row['Field']];
        }
    }
    
    
        $query = "UPDATE $table SET " . $fields . " where `perent`='$pkval' AND `startTime` > DATE(NOW())"; 
        
    if($result = mysql_query($query)) 
    {
        $data["Suucess"] = "Data Update Successfully";
         return $data;
    }
    else
    {
        echo(mysql_error());    
    }
    
    
   
} 
//END db_update 


function db_delete($table, $pk, $pkval){ 
    $query = "DELETE FROM ".$table." WHERE ".$pk." = ".$pkval;      
    if($result = mysql_query($query)) return(0); 
    else echo(mysql_error()); 
} 
//END db_delete 


function db_select($table , $cols='*',$where='1',$orderby='',$groupby='',$limit='') 
    {
       $query ="SELECT $cols FROM $table WHERE $where $orderby $groupby $limit";
        
     //  mail("mitul@mobispector.com", "mail", $query);     
    //   echo $query;
        $result =  mysql_query($query);
        $ret_arr = array();
        while($row = mysql_fetch_assoc($result))
        {
            
           $row1 = array();
           foreach ($row as $key=>$values)
           {
                $row1[$key] = stripslashes($values);
           }     
           if(isset($row['photo']) && $row['photo']!="")
                {
                    $row1['photo'] = base64_encode(file_get_contents($row["photo"]));
                }                                                                       
         /* if($_POST['needImage']=="Yes")
          {
                if(isset($row['photo']) && $row['photo']!="")
                {
                    $row1['photo'] = base64_encode(file_get_contents($row["photo"]));
                }   
          }
          else
          {
              */
               /* if(isset($row['photo']) && $row['photo']!="")
                {
                    $row1['photo'] = "http://tymepass.mobispector.com/" .$row["photo"];
                }  */
        /*  } 
              */
            
           
           $ret_arr[] = $row1; 
        }
        return $ret_arr;
    }
    
function db_query($query )
    {
       if($result = mysql_query($query))
       {
            $data['success'] = "Seccess" ;
             return $data;   
       } 
       else 
       {
            echo(mysql_error());
       }
    }
    

}
