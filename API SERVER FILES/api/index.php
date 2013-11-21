<?php

date_default_timezone_set("UTC");
include("dbclass1.php");
$db = new db_class();
$siteurl = "https://tymepass.com/api/";
 $_REQUEST = array_merge($_GET, $_POST);
   
   
$action = $_REQUEST['action'];


if(isset($_REQUEST['CURRENTUSERID'])){
    $zone = $_REQUEST['CURRENTUSERID'];
    $time = $db->db_select("user", "timeZone", "serverId= '" . @$_REQUEST['CURRENTUSERID'] . "'");    
    $time =  $time[0]['timeZone'];
}


if (count($_REQUEST) <= 2) {
    $_REQUEST = json_decode("[" . file_get_contents("php://input") . "]");
    $_REQUEST = (array) $_REQUEST[0];
}


if(isset($_REQUEST['CURRENTUSERID'])){
    $zone = $_REQUEST['CURRENTUSERID'];
    $time = $db->db_select("user", "timeZone", "serverId= '" . @$_REQUEST['CURRENTUSERID'] . "'");    
    $time =  $time[0]['timeZone'];
}


   $_REQUEST['userTimeZone'] = @$time;
   $_REQUEST['CURRENTUSERID'] = @$zone;
@header('Content-Type: application/json; charset= ');
echo "[";


include("functions.php");
$_POST['needImage'] = "No";
switch ($action) {
     
    case "newuser": {
        
        if(!isset($_REQUEST['dateOfBirth']) || $_REQUEST['dateOfBirth']=="")
        {
$_REQUEST['dateOfBirth'] = "1970-01-01 01:00:00";

//            $_REQUEST['dateOfBirth'] = "0000-00-00 00:00:00";
        }
        $img = @$_REQUEST['photo'];
        if($img!="")
        {
            $img = str_replace('data:image/png;base64,', '', $img);
            $img = str_replace(' ', '+', $img);
            $data = base64_decode($img);
            $file = "upload/". uniqid() . '.png';
            $success = file_put_contents("../".$file, $data);
            $success = file_put_contents($file, $data);
            $_REQUEST['photo'] = $file;
        }
        else
        {
            $_REQUEST['photo'] = "";
        }

        if(isset($_REQUEST['facebookId']) && $_REQUEST['facebookId']!=-1)
        {

            $data = $db->db_select("user", "*", "email= '" . @$_REQUEST['email'] . "'");
            if (!empty($data))
            {
                $data1 = array("id" => $data[0]['serverId']);;
                echo json_encode($data1) . "]";
                exit;
            }
            else
            {
                $data = $db->db_select("user", "*", "facebookId= '" . @$_REQUEST['facebookId'] . "'");
                if (!empty($data))
                {
                    $data1 = array("id" => $data[0]['serverId']);;
                    echo json_encode($data1) . "]";
                    exit;
                } else
                {

                    $data1 = $db->db_insert("user");
                    echo json_encode($data1) . "]";
                    exit;
                }
            }
             
        }
        else if(isset($_REQUEST['twitterId']) && $_REQUEST['twitterId']!=-1)
        {
$_REQUEST['dateOfBirth'] = "1970-01-01 01:00:00";
  

          $data = $db->db_select("user", "*", "twitterId= '" . @$_REQUEST['twitterId'] . "'");
            if (!empty($data))
            {
                $data1['error'] = "Twitter Id Already Exist";
            } else
            {
                $data1 = $db->db_insert("user");
            }

        }
        else if($_REQUEST['email']== "-1")
        {
             $data1['id'] = "-1"; 
        }
        else
        {
            $data = $db->db_select("user", "*", "email= '" . @$_REQUEST['email'] . "'");
            if (!empty($data))
            {
                $data1['error'] = "Email Address Already Exist";
            } else
            {
                $data1 = $db->db_insert("user");
            }
        }
$data123['photo'] = $siteurl.$file;
        echo json_encode($data1);
        break;
    }

    case "updateUDID" :  {
            $query = "UPDATE `user` SET `deviceId`='' WHERE `deviceId`='". $_REQUEST['deviceId'] ."'";
            $db->db_query($query);
            $query = "UPDATE `user` SET `deviceId`='". $_REQUEST['deviceId'] ."' WHERE `deviceId`='". $_REQUEST['serverId'] ."'";
            $db->db_query($query);
            break;
        }

    case "editUser":        {
        $no_update = array();
        if (@$_REQUEST['password'] == "" || @$_REQUEST['password'] == "0" || !isset($_REQUEST['password'])) {
            $no_update[] = 'password';
        }
        if (@$_REQUEST['twitterId'] == "" || @$_REQUEST['twitterId'] == "0" || !isset($_REQUEST['twitterId'])) {
            $no_update[] = 'twitterId';
        }
        if (@$_REQUEST['facebookId'] == "" || @$_REQUEST['facebookId'] == "0" || !isset($_REQUEST['facebookId'])) {
            $no_update[] = 'facebookId';
        }
        if (@$_REQUEST['dateCreated'] == "" || @$_REQUEST['dateCreated'] == "0" || !isset($_REQUEST['dateCreated'])) {
            $no_update[] = 'dateCreated';
        }
        $no_update[] = 'iCallSync';
        $img = @$_REQUEST['photo'];
        if($img!="")
        {
            $img = str_replace('data:image/png;base64,', '', $img);
            $img = str_replace(' ', '+', $img);
            $data = base64_decode($img);
            $file = "upload/". $_REQUEST['serverId'] ."-". uniqid() . '.png';
            $success = file_put_contents("../".$file, $data);
            
            $success = file_put_contents($file, $data);
            $_REQUEST['photo'] = $file;
            $query = "INSERT INTO invitation (`fromUser`,`type`, `dateCreated` , `eventId`) VALUES ('". $_REQUEST['serverId'] ."', 'UserPicture', '" . date("Y-m-d H:i:s") . "', '0')";
            $db->db_query($query);
        }
        else
        {
        $dataphoto = $db->db_select("user", "photo", "serverId= '". $_REQUEST['serverId'] ."'");
            $no_update[] ='photo';
           $file=$dataphoto[0]['photo'];
        }

        $data1 = $db->db_update("user", $no_update);
        $data123['id'] = 201;
$data123['photo'] = $siteurl.$file;
        echo json_encode($data123);
        break;
    }

    case "login":           {
        $data = $db->db_select("user", "*", "email= '" . @$_REQUEST['email'] . "'");
        if (!empty($data)) {
            $where = "email='" . @$_REQUEST['email'] . "' and password='" . @$_REQUEST['password'] . "'";
           $res = $db->db_select("user", "*", $where);
            if (empty($res)) {
                $data1['user'] = $res;
                $data2['statusCode'] = "404";
                echo json_encode($data1) . ",";
                echo json_encode($data2);
            } else {
                $data2['user'] = $res;

                $data2['user'][0]["key"] = $res[0]['serverId'];
                $data3['statusCode'] = "200";
                echo json_encode($data2) . ",";
                echo json_encode($data3);
            }
        } else {

            $where = "email='" . @$_REQUEST['email'] . "' and password='" . @$_REQUEST['password'] . "'";
            $res = $db->db_select("user", "*", $where);
            if (empty($res)) {

                $data1['user'] = $res;
                $data2['statusCode'] = "401";
                echo json_encode($data1) . ",";
                echo json_encode($data2);
            } else {
                $data['user'] = $res;
                $data['user'][0]["key"] = $res[0]['serverId'];
                $data1['statusCode'] = "200";
                echo json_encode($data);
            }
        }

        break;
    }

    case "updateDeviceToken": {
        $query = "UPDATE `user` SET `deviceId`='' WHERE `deviceId`='". $_REQUEST['deviceId'] ."'";
        $db->db_query($query);
        $query = "UPDATE `user` SET `deviceId`='". $_REQUEST['deviceId'] ."' WHERE `serverId`='". $_REQUEST['id'] ."'";
        $db->db_query($query);
        break;
    }

    case "syncShort": {

        if(isset($_REQUEST['deviceId']))
        {
            $query = "UPDATE `user` SET `deviceId`='' WHERE `deviceId`='". $_REQUEST['deviceId'] ."'";
            $db->db_query($query);
            $query = "UPDATE `user` SET `deviceId`='". $_REQUEST['deviceId'] ."' WHERE `serverId`='". $_REQUEST['id'] ."'";
            $db->db_query($query);
        }
        $query = "UPDATE `user` SET `timeZone`='". $_REQUEST['timeZone'] ."' WHERE `serverId`='". $_REQUEST['id'] ."'";
        $db->db_query($query);

        $data = $db->db_select("user", "*", "serverId='" . @$_REQUEST['id'] . "'");
        $data[0]['userId'] =   $_REQUEST['id'];
        $data[0]['dateCreated'] = changeTotimezone($row['dateCreated']);
        $data[0]['dateModified'] = changeTotimezone($row['dateModified']);
        $res['UsersAndEvents'][] = $data[0];
         
         
        $data = $db->db_select("events", "*", "creatorId='" . @$_REQUEST['id'] . "'");
        foreach ($data as $row) {
           
           $row['title'] = mb_check_encoding($row['title'], 'UTF-8') ? $row['title'] : utf8_encode($row['title']);
           
           $row['info'] = mb_check_encoding($row['info'], 'UTF-8') ? $row['info'] : utf8_encode($row['info']);
            $row['serverId'] = $row['id'];
            $row['eventId'] = $row['id'];
            $row['key'] = $row['id'];
            $row['creator'] = $row['creatorId'];
            $row['invitedBy'] = $row['creatorId'];
            $row['attending'] = 1;
            $row['startTime'] =changeTotimezone($row['startTime']);
            $row['recurringEndTime'] = changeTotimezone($row['recurringEndTime']);
            $row['endTime'] = changeTotimezone($row['endTime']);
            $row['dateModified'] = changeTotimezone($row['dateModified']);
            $row['dateCreated'] = changeTotimezone($row['dateCreated']);
            $row['reminderDate'] = changeTotimezone($row['reminderDate']);
                        $row['locations'][] = array("name" => $row['location']) ;
            //$row['chield'] =  $db->db_select("events", "id", " perent='".$row['id']  ."'");
            $res['UsersAndEvents'][] = $row;
        }

// jason - I have removed AND attending=1 from this line so we get all the user events to the iPhone.
        $data = $db->db_select("invitation", "eventId , attending, isGold", " `type` = 'TymepassEvent' AND `toUser` = '" . @$_REQUEST['id'] ."'");
        $ids = array();
        $attending = array();
        $isGold = array();
        foreach ($data as $row)
        {
            $ids[] = $row['eventId'];
            $attending[$row['eventId']] = $row['attending'];
            $isGold[$row['eventId']] = $row['isGold'];
        }
        if(count($ids)>0)
        {
            $myid = implode(",", $ids);
             
            $data = $db->db_select("events", "*", "id in ($myid)  AND creatorId != '" . @$_REQUEST['id'] . "'");
           
            foreach ($data as $row) {
                $row['serverId'] = $row['id'];
                $row['eventId'] = $row['id'];
                $row['key'] = $row['id'];
                $row['creator'] = $row['creatorId'];
                $row['invitedBy'] = $row['creatorId'];
                $row['recurring'] = 0;
                $row['attending'] = $attending[$row['id']];
                $row['isGold'] = $isGold[$row['id']];
                $row['startTime'] =changeTotimezone($row['startTime']);
                $row['recurringEndTime'] = changeTotimezone($row['recurringEndTime']);
                $row['endTime'] = changeTotimezone($row['endTime']);
                $row['dateModified'] = changeTotimezone($row['dateModified']);
                $row['dateCreated'] = changeTotimezone($row['dateCreated']);
                $row['reminderDate'] = changeTotimezone($row['reminderDate']);
                $row['iCalId'] = iCal($row['id'],$_REQUEST['id'] );
                $row['locations'][] = array("name" => $row['location']) ;
                $res['UsersAndEvents'][] = $row;
            }
        }
        echo json_encode($res);

        break;
    }
     
    case "getuser":         {
        $_POST['needImage'] = "No";  
        $where = "email='" . @$_REQUEST['email'] . "'";
        $res = $db->db_select("user", "*, serverId as `key`", $where);
        if (empty($res)) {
            $data1['error'] = "Email Id not Registerd";
            echo json_encode($data1);
        } else {
            $data['user'] = $res;
            echo json_encode($data);
        }
        break;
    }
     
    case "getUserById":     {
        $data = $db->db_select("user", "*", "serverId='" . @$_REQUEST['id'] . "'");
        $res['user'] = array();
        if (!empty($data)) {

            $data[0]['dateCreated'] = changeTotimezone($data[0]['dateCreated']);
            $data[0]['dateModified'] = changeTotimezone($data[0]['dateModified']);
            if($data[0]['dateOfBirth']!="")
            {
                $data[0]['dateOfBirth'] = changeTotimezone($data[0]['dateOfBirth']);
            }
                
            $res['user'] = $data;
            $res['user'][0]["key"] = $data[0]['serverId'];
        }
        echo json_encode($res);
        break;
    }
     
    case "getUserByTwitter":{
        $data = $db->db_select("user", "*", "twitterId='" . @$_REQUEST['twitterId'] . "'");
        $res['user'] = array();
        if (!empty($data)) {

            $data[0]['dateCreated'] = changeTotimezone($data[0]['dateCreated']);
            $data[0]['dateModified'] = changeTotimezone($data[0]['dateModified']);
            $data[0]['dateOfBirth'] = changeTotimezone($data[0]['dateOfBirth']);
            $res['user'] = $data;
            $res['user'][0]["key"] = $data[0]['serverId'];
        }
        echo json_encode($res);
        break;
    }

    case "confirmInvitation": {
        $data = $db->db_select("invitation", "*", "id='" . @$_REQUEST['id'] . "'");
        $status['status'] = 400;
        if (!empty($data)) {
            $_REQUEST['from'] = $data[0]['toUser'];
            $_REQUEST['to'] = $data[0]['fromUser'];
            $_REQUEST['status'] = "1";

            $uid = $data[0]['toUser'];
            $friendId = $data[0]['fromUser'];
            $where = "(`from`= '" . $data[0]['toUser'] . "' and `to`= '" . $data[0]['fromUser'] . "' )";
            $where .= " or (`from`= '" . $data[0]['fromUser'] . "' and `to`= '" . $data[0]['toUser'] . "' )";
            $dd = $db->db_select("friend", "*", $where);
            if (empty($dd)) {
                $_REQUEST['dateCreated'] = date('Y-m-d H:i:s');
                $db->db_insert("friend");
                $query = "UPDATE  invitation SET status = 1 , dateAccepted = '" . date('Y-m-d H:i:s') . "' WHERE id='". $_REQUEST['id'] ."'";
                $db->db_query($query);
                
                $query = "INSERT INTO invitation (toUser, fromUser, dateCreated, dateAccepted, `type`) VALUES('". $data[0]['fromUser'] ."', '". $data[0]['toUser'] ."',  '" . date('Y-m-d H:i:s') . "', '" . date('Y-m-d H:i:s') . "','UserRequestAccepted')";
                $db->db_query($query);
                $status['status'] = 201;
            }

            $where = "serverId = '$uid'";
            $data = $db->db_select("user", "name", $where);
            $UserName = $data[0]['name'];

            $where = "serverId = '$friendId'";
            $data = $db->db_select("user", "deviceId", $where);
            $deviceId = $data[0]['deviceId'];

            $msg = "You are now Tymepass friends with $UserName";
            sendMessageToPhone($deviceId, $msg , "FriendRequestConfirm", $uid);
        }

        //$db->db_delete("invitation", "id", @$_REQUEST['id']);
        echo json_encode($status);
        break;
    }

    case "newEvent":   {
        $dat = array();
        if(isset($_REQUEST['iCalId']) && $_REQUEST['iCalId']!="")
        {
            $where = "`iCalId` = '". $_REQUEST['iCalId'] ."' AND `creatorId` = '". $_REQUEST['creatorId'] ."' AND `title` = '". addslashes($_REQUEST['title']) ."'";
            $dat = $db->db_select("events", "id", $where);
        }
        if(empty($dat))
        {
            $img = @$_REQUEST['photo'];
            $photo_path='';
            if($img!="")
            {
                $img = str_replace('data:image/png;base64,', '', $img);
                $img = str_replace(' ', '+', $img);
                $data = base64_decode($img);
                $file = "upload/".$_REQUEST['creatorId']."-". uniqid() . '.png';
                 $success = file_put_contents("../".$file, $data);
               
                $success = file_put_contents($file, $data);
                $_REQUEST['photo'] = $file;
                $photo_path = $siteurl.$file;
            }
            if(isset($_REQUEST['reminderTime']) && $_REQUEST['reminderTime']!=0)
            {
                $_REQUEST['reminderTime'] = $_REQUEST['reminderTime'] / 60;
            }
            $_REQUEST['servertime'] = date("Y-m-d H:i", strtotime($_REQUEST['startTime'])- $_REQUEST['timezone']);
            $_REQUEST['startTime'] = date("Y-m-d H:i", strtotime($_REQUEST['startTime'])- $_REQUEST['timezone']);
            $_REQUEST['endTime'] = date("Y-m-d H:i", strtotime($_REQUEST['endTime'])- $_REQUEST['timezone']);
            $_REQUEST['recurringEndTime'] = date("Y-m-d H:i", strtotime($_REQUEST['recurringEndTime'])- $_REQUEST['timezone']);
            
            $res = $db->db_insert("events");
            $eventId =   $res['id'];
            $res['chield'] = array();
            $res['photo']= $photo_path;//$siteurl.$file;
            $_REQUEST['isGold']=0;
            if($_REQUEST['title']!="Happy Birthday!")
            {
                $res['chield'] =  recursion($eventId);
            }

            if($_REQUEST['isOpen']=='1')
            {
                $query = "INSERT INTO invitation (`fromUser`,`type`, `dateCreated` , `eventId`) VALUES ('". $_REQUEST['creatorId'] ."', 'OpenEvent', '" . date("Y-m-d H:i:s") . "', '". $eventId ."')";
                $db->db_query($query);
                send_OpenEventNotification($_REQUEST['creatorId'],$eventId, $res['chield'] );
            }
        }
        else
        {
            $res["id"] = $dat[0]['id'];
        }
        echo json_encode($res);
        break;
    }

    case "deleteEvent":   {
        //      mail("mitul@mobispector.com", "delete Events", print_r($_REQUEST, true));
        $db->db_query("DELETE FROM events where  id in (" . implode(",", (array) $_REQUEST['ids']) . ")");
        $db->db_query("DELETE FROM invitation where  eventId in (" . implode(",", (array) $_REQUEST['ids']) . ")");
        $db->db_query("DELETE FROM message where  eventId in (" . implode(",", (array) $_REQUEST['ids']) . ")");
        $db->db_query("DELETE FROM events where  perent in (" . implode(",", (array) $_REQUEST['ids']) . ")");
        break;
    }

    case "checkEvents":     {

        $ids = $_REQUEST['ids'];
        $d = $db->db_select("events", "id", "id in (" . implode(",", (array) $_REQUEST['ids']) . ")");

        $data  = array();
        foreach ($d as $row)
        {
            $data[]  = $row['id'];
        }

        $mm['entities'] = array();
        foreach ($ids as $key => $val)
        {
            if(!in_array($val, $data))
            {
                $valu['key'] = $val;
                $mm['entities'][] = $valu;
            }
        }


        echo json_encode($mm) ;

        break;
    }

    case "editEvent":     {

        $_REQUEST['id'] = $_REQUEST['serverId'];
        $dd  = $db->db_select("events", "creatorId,photo,isOpen" , "id='" . $_REQUEST['id'] . "'");
        $_REQUEST['creatorId'] = $dd[0]['creatorId'];

        $existingEventIsOpen = $dd[0]['isOpen'];


        $img = @$_REQUEST['photo'];
        $photo_path='';
        if($img!="")
        {
            $img = str_replace('data:image/png;base64,', '', $img);
            $img = str_replace(' ', '+', $img);
            $data = base64_decode($img);
            $file = "upload/".$_REQUEST['id']."-". uniqid() . '.png';
            $success = file_put_contents("../".$file, $data);
            $success = file_put_contents($file, $data);
            
            $_REQUEST['photo'] = $file;
            $query = "INSERT INTO invitation (`fromUser`,`type`, `dateCreated` , `eventId`) VALUES ('". $_REQUEST['creatorId'] ."', 'EventPicture', '" . date("Y-m-d H:i:s") . "', '". $_REQUEST['id'] ."')";
            $db->db_query($query);
            $photo_path = $siteurl.$file;
        }
        else
        {
$file =$dd[0]['photo'];
$_REQUEST['photo']=$dd[0]['photo'];
$photo_path = $file;
            $no_update[] ='photo';
        }
        $no_update[] = "creatorId";
        //$no_update[] = "perent";

        if(isset($_REQUEST['reminderTime']) && $_REQUEST['reminderTime']!=0)
        {
            $_REQUEST['reminderTime'] = $_REQUEST['reminderTime'] / 60;
        }
        
            $_REQUEST['servertime'] = date("Y-m-d H:i", strtotime($_REQUEST['startTime'])- $_REQUEST['timezone']);
            $_REQUEST['startTime'] = date("Y-m-d H:i", strtotime($_REQUEST['startTime'])- $_REQUEST['timezone']);
            $_REQUEST['endTime'] = date("Y-m-d H:i", strtotime($_REQUEST['endTime'])- $_REQUEST['timezone']);
            $_REQUEST['recurringEndTime'] = date("Y-m-d H:i", strtotime($_REQUEST['recurringEndTime'])- $_REQUEST['timezone']);
            $_REQUEST['perent'] = 0;
            
            $where = "id = '" . $_REQUEST['serverId'] . "' AND
                    recurringEndTime = '" . $_REQUEST['recurringEndTime'] . "' AND
                            endTime = '" . $_REQUEST['endTime'] . "' AND
                                    startTime = '" . $_REQUEST['startTime'] . "'";
            $checkOld = $db->db_select("events", "*", $where);
            $res = $db->db_update("events", $no_update);
            
            $dd  = $db->db_select("events", "creatorId" , "id='" . $_REQUEST['id'] . "'");
            $_REQUEST['creatorId'] = $dd[0]['creatorId'];
            // if the event is not open then just do a normal edit event notification
            if($_REQUEST['isOpen']!=1)
            {
                send_EventEditNotification($_REQUEST['serverId']);    
            }
            $data = array(); 
            $query = "INSERT INTO invitation (`fromUser`,`type`, `dateCreated` , `eventId`) VALUES ('". $_REQUEST['creatorId'] ."', 'EventUpdate', '" . date("Y-m-d H:i:s") . "', '". $_REQUEST['serverId'] ."')";
            $db->db_query($query);     
        
            if($_REQUEST['parentServerId'] == 0 && $_REQUEST['saveCurrentEventOnly']==0)
            {
                $data['chield'] =  recursionOnlyChield($_REQUEST['id']);
                if($_REQUEST['isOpen']==1)
                {
               		//check if the existing event is already open, if it is then just send out that the event has been modified
                	if ($existingEventIsOpen==0){
                  		send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id'], $data['chield']);     
                	}
               		else {
                 		send_EventEditNotification($_REQUEST['serverId']);   
                	}
                }
            }
            else if($_REQUEST['saveCurrentEventOnly']==0)
            {
                
                $quety = "UPDATE events set recurringEndTime = '". $_REQUEST['startTime']  ."' where id='". $_REQUEST['parentServerId'] ."'";
                $db->db_query($quety);
                $quety = "UPDATE events set recurringEndTime = '". $_REQUEST['startTime']  ."' where perent ='". $_REQUEST['parentServerId'] ."' AND  `startTime` < '" .$_REQUEST['startTime'] . "' ";
                $db->db_query($quety);   
                $quety = "UPDATE events set `perent`='0' where id='". $_REQUEST['serverId'] ."'";
                $db->db_query($quety);
                $data['chield'] =  recursionAll($_REQUEST['parentServerId'], $_REQUEST['serverId']);
                if($_REQUEST['isOpen']==1)
                {
                    
                    //check if the existing event is already open, if it is then just send out that the event has been modified
                	if ($existingEventIsOpen==0){
                  		send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id'], $data['chield']);     
                	}
               		else {
                 		send_EventEditNotification($_REQUEST['serverId']);   
                	}  
                    
                   // send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id'], $data['chield']);     
                }
            }
            else if($_REQUEST['saveCurrentEventOnly']==1)
            {
                $quety = "UPDATE events set `perent`='0', `recurring`='0' , recurringEndTime = '0000-00-00' where id='". $_REQUEST['serverId'] ."'";
                $db->db_query($quety);
 if($_REQUEST['isOpen']==1)
                {
                //send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id']   );   
                //check if the existing event is already open, if it is then just send out that the event has been modified
                	if ($existingEventIsOpen==0){
 		               	send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id']   );   
 					}
               		else {
                 		send_EventEditNotification($_REQUEST['serverId']);   
                	}
}  
            }
        $data['photo'] = $photo_path;//$siteurl.$file;
        $data["id"] = 201;
        echo json_encode($data) ."]";
        exit;
        break;
    }

    case "unFriend" :  {
        $where = "(`from`= '" . $_REQUEST['to'] . "' and `to`= '" . $_REQUEST['from'] . "' )";
        $where .= " or (`from`= '" . $_REQUEST['from'] . "' and `to`= '" . $_REQUEST['to'] . "' )";
        $query = "DELETE from friend WHERE $where";
        $db->db_query($query);
       
        $where = "((`toUser`= '" . $_REQUEST['to'] . "' and `fromUser`= '" . $_REQUEST['from'] . "' )";
        $where .= " or (`toUser`= '" . $_REQUEST['from'] . "' and `fromUser`= '" . $_REQUEST['to'] . "' )) AND (`type`='TymepassUser' OR `type`='FacebookUser' OR `type`='UserRequestAccepted')";
        $query = "DELETE from invitation WHERE $where";
       
        $db->db_query($query);
        $status['status'] = 201;
        echo json_encode($status);
        break;
    }

    case "getNewsreel" :     {
        $_POST['needImage'] = "No";
        $where = "`from`= '" . $_REQUEST['id'] . "'  OR  `to` = '" . $_REQUEST['id'] . "'";
        $data = $db->db_select("friend", "*", $where);
        $ids = "";
        foreach ($data as $row) {
            if ($ids == "") {
                if ($row['from'] == $_REQUEST['id']) {
                    $ids = $row['to'];
                } else {
                    $ids = $row['from'];
                }
            } else {
                if ($row['from'] == $_REQUEST['id']) {
                    $ids .= ", " . $row['to'];
                } else {
                    $ids .= ", " . $row['from'];
                }
            }
        }
        $res = array();
        $where = "";
        if ($ids != "") {
            $where = "creatorId in ($ids) order by dateModified";
            $res = $db->db_select("events", "*", $where);
        }

        $data = array();
        $data['news'] = array();
        foreach ($res as $row) {
            $row["eventId"] = $row['id'];
            $row["userId"] = $row['creatorId'];
            $row["eventTitle"] = $row['title'];
            $row["eventStartTime"] = changeTotimezone($row['startTime']);
            $row["recurringEndTime"] = changeTotimezone($row['recurringEndTime']);
            $row["type"] = "event";
            $row["eventOpen"] = 0;
            $row["relationshipCreateDate"] = "";
            $data['news'][] = $row;
        }
        echo json_encode($data);

        break;
    }
    
    case "getNewsreelNew" :    {
        $_POST['needImage'] = "No";
            $result = array();
            $userprofileid=$_REQUEST['id'];          
            
            //get list of friend ids
            
            $where = "(`from`= '" . $_REQUEST['id'] . "' AND `toHide` = '0'  )  OR  (`to` = '" . $_REQUEST['id'] . "' AND `fromHide` = '0' )";
            $data = $db->db_select("friend", "*", $where);
            $ids = "";
            foreach ($data as $row) {
                if ($ids == "") {
                    if ($row['from'] == $_REQUEST['id']) {
                        $ids = $row['to'];
                    } else {
                        $ids = $row['from'];
                    }
                } else {
                    if ($row['from'] == $_REQUEST['id']) {
                        $ids .= ", " . $row['to'];
                    } else {
                        $ids .= ", " . $row['from'];
                    }
                }
            }
            
          /*  $where = "`type` = 'TymepassUser' AND `fromUser` in($ids) AND `toUser` in($ids) AND `fromUser` !='" . $_REQUEST['id'] . "' AND `toUser` !='" . $_REQUEST['id'] . "' AND `status` = '1' GROUP BY `id`";
            $friends = $db->db_select("invitation", "id , toUser, type, fromUser,  dateAccepted as dateCreated ", $where);
            foreach($friends as $row)
            {
                $where =  "`serverId` = '". $row['toUser'] ."'";
                $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                $row['type'] = "FriendRequestAccepted";
                $result['news'][] = $row;
            }
*/
            // for getting friend open event
   //         $where = "`type` = 'TymepassEvent' AND (`toUser` ='" . $_REQUEST['id'] . "' OR (`toUser` in($ids) AND `fromUser` in($ids))) AND `fromUser`!='" . $_REQUEST['id'] . "'  AND `eventId` != 0 AND `stealth`!=1 AND status= 1 AND isGold = 0 AND attending = 1";
		   //$where = "`type` = 'TymepassEvent' AND (`toUser` ='" . $_REQUEST['id'] . "' OR (`toUser` in($ids) AND `fromUser` in($ids))) AND `toUser`='" . $_REQUEST['id'] . "'  AND `eventId` != 0 AND `stealth`!=1 AND status= 1 AND isGold = 0 AND attending = 1";
		   $where = "`type` = 'TymepassEvent' AND (`toUser` ='" . $_REQUEST['id'] . "' OR (`toUser` in($ids) AND `fromUser` in($ids))) AND `toUser`='" . $_REQUEST['id'] . "'  AND `eventId` != 0 AND `invitation`.`stealth`!=1 AND status= 1 AND `invitation`.isGold = 0 AND invitation.attending = 1 AND invitation.eventId = events.id AND events.isOpen=1";
            $friends = $db->db_select("invitation,events", "invitation.*", $where);
            $eventIds  = "";
            foreach($friends as $row)
            {
                if($row['attending']==1)
                {
                    $eventIds .= "," . $row['eventId'];
                    $row['type'] = "OpenEvent";
                }                                         
                $where =  "`id` = '". $row['eventId'] ."' AND `isPrivate`!=1";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                $row['type'] = "OpenEvent";
                if(!empty($row['eventInfo']))
                {
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
           
            } 
            
            // When friend A invites friend B to an event and friend B accepts the invitation, friend C sees in his newsreel that friend A has created an open event. What friend C should be seeing instead is the following: "friend B is attending <event name>." 
            $where = "`type` = 'friendTofriendOpenEventNotific' AND `toUser` ='" . $_REQUEST['id'] . "' AND `eventId` != 0 AND status= 1 AND attending = 3";
            $friends = $db->db_select("invitation", "*", $where);            
            foreach ($friends as $row) {
                $where = "`id` = '" . $row['eventId'] . "' AND `isPrivate`!=1";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                $row['type'] = "friendTofriendOpenEventNotification";
                if (!empty($row['eventInfo'])) {
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
            }

            $where = "`type` = 'EventRequestAccepted' AND (`toUser` ='" . $_REQUEST['id'] . "' OR (`toUser` in($ids) AND `fromUser` in($ids))) AND `fromUser`!='" . $_REQUEST['id'] . "'  AND `eventId` != 0 AND `stealth`!=1";
//            $where = "`type` = 'EventRequestAccepted' AND (`toUser` ='" . $_REQUEST['id'] . "' OR `toUser` in($ids)) AND `fromUser`!='" . $_REQUEST['id'] . "'  AND `eventId` != 0 AND `stealth`!=1"; // qtm 6-8-13
            //$where = "`type` = 'EventRequestAccepted' AND ((`toUser` ='" . $_REQUEST['id'] . "' OR `toUser` in($ids)) OR (`type` = 'OpenEvent' AND `toUser` in($ids)) ) AND `fromUser`!='" . $_REQUEST['id'] . "'  AND eventId != 0 GROUP BY eventId";
           // $where = "((`type` = 'EventRequestAccepted' AND (`toUser` ='" . $_REQUEST['id'] . "' OR `toUser` in($ids))) OR (`type` = 'OpenEvent' AND `toUser` in($ids))) AND `fromUser`!='" . $_REQUEST['id'] . "'  AND `eventId`!='0'";
            $friends = $db->db_select("invitation", "*", $where);
            $eventIds  = "";
            foreach($friends as $row)
            {
                if($row['attending']==1)
                {
                    $eventIds .= "," . $row['eventId'];
                    $row['type'] = "EventRequestAccepted";
                }                                         
                $where =  "`id` = '". $row['eventId'] ."' AND `isPrivate`!=1 AND `isPrivate`!=1 AND creatorId!='".$_REQUEST['CURRENTUSERID']."'";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                $row['type'] = "EventRequestAccepted";
                if(!empty($row['eventInfo']))
                {
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
           
            } 
            
            /*$where = "`type` = 'EventRequestMayBe' AND `toUser` ='" . $_REQUEST['id'] . "' AND eventId != 0";
            $friends = $db->db_select("invitation", "*", $where);
            $eventIds  = "";
            foreach($friends as $row)
            {
                $row['type'] = "EventRequestMayBe";
                $where =  "`id` = '". $row['eventId'] ."'";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                if(!empty($row['eventInfo']))
                {
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
           
            }*/
            // Fetch Message List
            $where = " `creatorId` ='" . $_REQUEST['id'] . "'";
            $friends = $db->db_select("events", "id", $where);
            foreach($friends as $row)
            {
                $eventIds .= "," . $row['id'];
            }
            if($eventIds !="")
            {
                $eventIds = trim($eventIds, ",");
                //AND toUser in(select DISTINCT creatorId from message where eventId in ($eventIds) and creatorId != '".$_REQUEST['CURRENTUSERID']."')
//                 $where = "`type` = 'Message' AND eventId in ($eventIds) AND `fromUser`!='".$_REQUEST['CURRENTUSERID']."'";
                $where = "`type` = 'Message' AND eventId in ($eventIds) AND toUser in($ids) AND `fromUser`='".$_REQUEST['CURRENTUSERID']."' ";
                $friends = $db->db_select("invitation", "*", $where);
                foreach($friends as $row)
                {
                    $where =  "`id` = '". $row['eventId'] ."'";
                    $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                    $row['type'] = "EventMessage";
                    if(!empty($row['eventInfo']))
                    {
                        $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                        $result['news'][] = $row;
                    }
                }
            }
            //If user X has commented in an event I am attending or in an open event, this does not appear in my newsreel. It should as per our newsreel spec. 
            $where = "(`type` = 'EventRequestAccepted' AND  `fromUser`='" . $_REQUEST['id'] . "' AND attending = 0) OR (`type` = 'TymepassEvent' AND `toUser`='" . $_REQUEST['id'] . "' AND attending = 3)";
            $frnd_messa = $db->db_select("invitation", "*", $where);
            $msg_eventIds = "";
            foreach ($frnd_messa as $row) {
                $msg_eventIds .= "," . $row['eventId'];
            }
            if ($msg_eventIds != "") {
                $msg_eventIds = ltrim($msg_eventIds,',');
                $where = "`type` = 'Message' AND eventId in ($msg_eventIds) AND fromUser != '" . $_REQUEST['id'] . "'";
                $friends = $db->db_select("invitation", "*", $where);
                foreach ($friends as $row) {
                    $where = "`id` = '" . $row['eventId'] . "'";
                    $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                    $row['type'] = "EventMessage";
                    if (!empty($row['eventInfo'])) {
                        $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                        $result['news'][] = $row;
                    }
                }
            }
            
            
            // Fetch Gold Star  List
            $where = "`type` = 'TymepassEvent' AND `toUser` in($ids) AND `fromUser`='".$_REQUEST['CURRENTUSERID']."' AND isGold='1' AND eventId != 0 AND `stealth`!=1";
//            $where = "`type` = 'TymepassEvent' AND `toUser` in($ids) AND `fromUser`!='".$_REQUEST['CURRENTUSERID']."' AND isGold='1' AND eventId != 0 AND `stealth`!=1"; // qtm 6-8-13
            $friends = $db->db_select("invitation", "*", $where);
            $eventIds  = "";
            foreach($friends as $row)
            {
                if($row['attending']==1)
                {
                    $eventIds .= "," . $row['eventId'];
                }
                $where =  "`id` = '". $row['eventId'] ."' AND `isPrivate`!=1";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                $row['type'] = "GoldEvent";
                if(!empty($row['eventInfo']))
                {
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
            }
             
             
            // For the User Event Create
             
            
            $res = array();
            $where = "";
            if ($ids != "") {
                $where = "creatorId in ($ids) AND Hide='0' AND `perent`=0 and `isPrivate` = 0  and startTime > DATE(NOW()) order by dateModified  limit 50";
                $res = $db->db_select("events", "*", $where);
            }
            $EventIds = "";
            foreach ($res as $row) {
                $row["eventId"] = $row['id'];
                $EventIds .= $row['id'] . ",";
                $row["userId"] = $row['creatorId'];
                $row["eventTitle"] = $row['title'];
                $row["eventStartTime"] = changeTotimezone($row['startTime']);
                $row["recurringEndTime"] = changeTotimezone($row['recurringEndTime']);
                $row["type"] = "event";
                unset($row['photo']);
                $row["eventOpen"] = 0;
                if($_REQUEST['id'] != $row['creatorId'] )
                {
                    $where = '`toUser` = "'. $_REQUEST['id']. '" AND  `attending` = 1 AND `eventId` = "' .$row['id'] . '"';
                    $d = $db->db_select("invitation", "toUser", $where);
                    if(empty($d)){
                        $row["attending"] = 0;
                    }   else {
                        $row["attending"] = 1;
                    }
                }
                $row["relationshipCreateDate"] = "";
                //  $result['news'][] = $row;
            }

            #PROFILE EMAGE CHANEG PROFILE IMAGE
            //  echo $ids;
            if($ids!="")
            {
                $where = "`type` = 'UserPicture' AND `fromUser` in($ids) GROUP BY `fromUser` ORDER BY MAX(dateCreated) DESC";
                $friends = $db->db_select("invitation", "*", $where);
                foreach($friends as $row)
                {
                    $where =  "`serverId` = '". $row['fromUser'] ."'";
                    $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                    $row['type'] = "UserPicture";
                    $result['news'][] = $row;

                }
                 
            }
            if($EventIds!="")
            {
              //  $EventIds = $EventIds . "0";
                $where = "`type` = 'profilePick' AND `eventId` in($EventIds)";
                $friends = $db->db_select("invitation", "*", $where);
                foreach($friends as $row)
                {
                    $where =  "`id` = '". $row['eventId'] ."'";
                    $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $row['type'] = "EventPicture";
                    $result['news'][] = $row;

                }
                 
            }
            
             if($EventIds!="")
            {
               // $EventIds = $EventIds . "0";
               $EventIds = rtrim($EventIds,',');
                $where = "`type` = 'EventPicture' AND `eventId` in($EventIds)";
                $friends = $db->db_select("invitation", "*", $where);
                foreach($friends as $row)
                {
                    $where =  "`id` = '". $row['eventId'] ."'";
                    $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $row['type'] = "EventPicture";
                    $result['news'][] = $row;

                }
                 
            }
             
               //X is friends with Y (X is a friend of mine, Y can be anyone).
       
            // friends Requests
            if($ids !="")
            {
                $where = "(`type` = 'TymepassUser' OR `type` = 'FacebookUser' OR `type`='TwitterUser') AND ( `fromUser` in($ids) OR `toUser` in($ids) ) AND (`fromUser` = '". $_REQUEST['id'] ."' OR `toUser` = '". $_REQUEST['id'] ."')  AND `status` = '1'";
//                $where = "(`type` = 'TymepassUser' OR `type` = 'FacebookUser' OR `type`='TwitterUser') AND ( `fromUser` in($ids) OR `toUser` in($ids) ) AND `fromUser` != '". $_REQUEST['id'] ."' AND `toUser` != '". $_REQUEST['id'] ."'  AND `status` = '1'";//qtm - 6-8-13
                $friends = $db->db_select("invitation", "id , toUser, type, fromUser,  dateAccepted as dateCreated ", $where);
                foreach($friends as $row)
                {
                    /*$where =  "`serverId` = '". $row['fromUser'] ."'";
                    $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                     
                    $where =  "`serverId` = '". $row['toUser'] ."'";
                    $row['userInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                     
                     if ($row['toUser']==$userprofileid) {
                    $row['changed']='yes '.$row['toUser'];
                     $test['userInfo']=$row['userInfo'];
                      $test['friendInfo']=$row['friendInfo'];
                    $test['toUser'][0]=$row['toUser'][0];
                    $test['fromUser'][0]=$row['fromUser'][0];
                    
                     //$row="";
                     $row['toUser']=$test['fromUser'];
                     $row['fromUser'][0]=$test['toUser'][0];
                     $row['userInfo'][0]=$test['friendInfo'][0];
                     $row['friendInfo'][0]=$test['userInfo'][0];
                     }*/
                     //qtm change 9-8-13
                    if($ids == $row['toUser']){
                        $where =  "`serverId` = '". $row['fromUser'] ."'";
                        $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);

                        $where =  "`serverId` = '". $row['toUser'] ."'";
                        $row['userInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);

                    }else{
                        $where =  "`serverId` = '". $row['toUser'] ."'";
                        $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);

                        $where =  "`serverId` = '". $row['fromUser'] ."'";
                        $row['userInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                    }
                    // $photoz=$row['friendInfo'][0]['photo'];
                    // $row['friendInfo'][0]['photo']=$row['userInfo'][0]['photo'];
                    //$row['userInfo'][0]['photo']=$photoz;
                    
                    if ($row['fromUser']==$userprofileid) {
                    $row['changed']='yes '.$row['toUser'];
                     $test['userInfo']=$row['userInfo'];
                      $test['friendInfo']=$row['friendInfo'];
                    $test['toUser']=$row['toUser'];
                    $test['fromUser']=$row['fromUser'];
                    
                     //$row="";
                     $row['toUser']=$test['fromUser'];
                     $row['fromUser']=$test['toUser'];
                     $row['userInfo']=$test['friendInfo'];
                     $row['friendInfo']=$test['userInfo'];
                     }
                     
                     
                    $row['type'] = "UserFriends";
                    $result['news'][] = $row;

                }
            }
             
            //get list of  friend become of friends friend
            $fid = explode(', ', $ids);
            for ($f = 0; $f < count($fid); $f++) {
                $where = "(`type` = 'TymepassUser' OR `type` = 'FacebookUser' OR `type`='TwitterUser') AND (( `fromUser` = '".$fid[$f]."' AND `toUser` != '" . $_REQUEST['id'] . "') OR (`fromUser` != '" . $_REQUEST['id'] . "' AND `toUser` = '".$fid[$f]."') )  AND `status` = '1'";
                $friends = $db->db_select("invitation", "id , toUser, type, fromUser,  dateAccepted as dateCreated ", $where);
                foreach ($friends as $row) {                    
                    if ($fid[$f] == $row['toUser']) {
                        $where = "`serverId` = '" . $row['fromUser'] . "'";
                        $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);

                        $where = "`serverId` = '" . $row['toUser'] . "'";
                        $row['userInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                    } else {
                        $where = "`serverId` = '" . $row['toUser'] . "'";
                        $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);

                        $where = "`serverId` = '" . $row['fromUser'] . "'";
                        $row['userInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                    }
                   
                    if ($row['fromUser'] == $fid[$f]) {
                        $row['changed'] = 'yes ' . $row['toUser'];
                        $test['userInfo'] = $row['userInfo'];
                        $test['friendInfo'] = $row['friendInfo'];
                        $test['toUser'] = $row['toUser'];
                        $test['fromUser'] = $row['fromUser'];

                        //$row="";
                        $row['toUser'] = $test['fromUser'];
                        $row['fromUser'] = $test['toUser'];
                        $row['userInfo'] = $test['friendInfo'];
                        $row['friendInfo'] = $test['userInfo'];
                    }


                    $row['type'] = "UserFriends";
                    $result['news'][] = $row;
                }
            }
             

            for($i=0; $i<count($result['news']);$i++)
            {
                for($j=$i; $j<count($result['news']);$j++)
                {
                    if($result['news'][$i]['dateCreated'] < $result['news'][$j]['dateCreated'] )
                    {
                        $temp = $result['news'][$i];
                        $result['news'][$i] = $result['news'][$j];
                        $result['news'][$j] = $temp;
                    }
                }
            }
             
             
            echo json_encode($result);
            break;
        }       
     
    case "getNotificationsCount" :      {
      
        $where = "toUser  ='" . $_REQUEST['id'] . "' and readed=0  ORDER By id DESC";
      //  $myquery = "UPDATE invitation SET status=1 WHERE  toUser  ='" . $_REQUEST['id'] . "' " ;
        $myquery = "SELECT * FROM invitation WHERE status=1 limit 1" ;
        
        $dd = $db->db_select("invitation", "FromUser as `userKey` , id as `InvitationId`, type as invitationType , status as `InvitationStatus`, eventId, messagesCount", $where);
        $data['invitations'] = array();
        foreach ($dd as $row) {
            if ($row['InvitationStatus'] == 0) {
                $row['InvitationStatus'] = "pending";
            }
            if ($row['invitationType'] == "TymepassUser") {
                $row['invitationType'] = "user";
                $data['invitations'][] = $row;  
            }
            else if ($row['invitationType'] == "FacebookUser") {
                $row['invitationType'] = "user";
                $data['invitations'][] = $row;  
            }
            else if ($row['invitationType'] == "TwitterUser") {
                $row['invitationType'] = "user";
                $data['invitations'][] = $row;  
            }
            else if ($row['invitationType'] == "UserRequestAccepted") {
                $row['invitationType'] = "UserRequestAccepted";
                $d = $db->db_select("user", "name , surname, photo ", "serverId='" . $row['fromUser'] . "'");
                $row['user'] = @$d[0];
                $data['invitations'][] = $row;  
            }
            else if ($row['invitationType'] == "TymepassEvent") {
                $row['invitationType'] = "event";
                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                foreach ($d as $event) {
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['parentServerId'] = $event['perent'];
                    unset($event['perent'])  ;
                    $event['userKey'] = $event['creatorId'];
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            } 
            
            else if ($row['invitationType'] == "EventRequestAccepted") {
                $row['invitationType'] = "EventRequestAccepted";
                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                foreach ($d as $event) {
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['parentServerId'] = $event['perent'];
                    unset($event['perent'])  ;
                    $event['userKey'] = $event['creatorId'];
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            }
             else if ($row['invitationType'] == "EventRequestAcceptedGold") {
                $row['invitationType'] = "EventRequestAcceptedGold";
                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                foreach ($d as $event) {
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['parentServerId'] = $event['perent'];
                    unset($event['perent'])  ;
                    $event['userKey'] = $event['creatorId'];
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            }
            else if ($row['invitationType'] == "EventRequestMayBe") {
                $row['invitationType'] = "EventRequestMayBe";
                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                foreach ($d as $event) {
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['parentServerId'] = $event['perent'];
                    unset($event['perent'])  ;
                    $event['userKey'] = $event['creatorId'];
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            } 
              else if ($row['invitationType'] == "EditEvent") {
                $row['invitationType'] = "EditEvent";
                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                foreach ($d as $event) {
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['parentServerId'] = $event['perent'];
                    unset($event['perent'])  ;
                    $event['userKey'] = $event['creatorId'];
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            } 
            
            else if ($row['invitationType'] == "Message") {

                $row['invitationType'] = "message";
                $row['count'] = $row['messagesCount'];

                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                $event = array();
                foreach ($d as $event) {
                    $event['count'] = $row['messagesCount'];
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['userKey'] = $event['creatorId'];
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            }                                       
        }

        $res = array("Count" => count($data['invitations']));
        echo json_encode($res);
        break;
             
     }
         
    case "getfriends":  {
        $_POST['needImage'] = "No";   
        $where = "`from`= '" . $_REQUEST['id'] . "'  OR  `to` = '" . $_REQUEST['id'] . "'";
        $data = $db->db_select("friend", "*", $where);
        $ids = "";
        foreach ($data as $row) {
            if ($ids == "") {
                if ($row['from'] == $_REQUEST['id']) {
                    $ids = $row['to'];
                } else {
                    $ids = $row['from'];
                }
            } else {
                if ($row['from'] == $_REQUEST['id']) {
                    $ids .= ", " . $row['to'];
                } else {
                    $ids .= ", " . $row['from'];
                }
            }
        }
         
        $where = "";
        $res = array();
        if ($ids != "") {
            $where = " serverId in ($ids)";
            $res = $db->db_select("user", "*", $where);
        }

        $data = array();
        $data['friends'] = array();
        foreach ($res as $row) {
            $row["dateCreated"] = changeTotimezone($row['dateCreated']);
            $row["dateModified"] = changeTotimezone($row['dateModified']);
            $row["dateOfBirth"] = changeTotimezone($row['dateOfBirth']);
            $row["key"] = $row['serverId'];
            $data['friends'][] = $row;
        }

        echo json_encode($data);
        break;

    }

    case "getFriendsForMessage":  {
        $_POST['needImage'] = "No";
        $where = "(`from`= '" . $_REQUEST['id'] . "'  OR  `to` = '" . $_REQUEST['id'] . "') AND `dateUpdated` !='0000-00-00 00:00:00'  ORDER by dateUpdated desc ";
        $data = $db->db_select("friend", "*", $where);
        $ids = ""; 
        $data1['friends'] = array();
        foreach ($data as $row) {
                if ($row['from'] == $_REQUEST['id']) {
                    $ids = $row['to'];
                } else {
                    $ids = $row['from'];
                }
            $where = " serverId  = '$ids' ";
            $res = @$db->db_select("user", "*", $where);
            
            $res[0]['serverId'];
            $res[0]["dateCreated"] = changeTotimezone($res[0]['dateCreated']);
            $res[0]["dateModified"] = changeTotimezone($res[0]['dateModified']);
            $res[0]["dateOfBirth"] = changeTotimezone($res[0]['dateOfBirth']);
            $res[0]["key"] = $res[0]['serverId'];
            $data1['friends'][] = $res[0];
            
        
        }
     
        echo json_encode($data1);
        break;

    }

    case "getGAEFriends":  {
        $where = "`from`= '" . $_REQUEST['id'] . "'  OR  `to` = '" . $_REQUEST['id'] . "'";
        $data = $db->db_select("friend", "*", $where);
        $ids = "";
        foreach ($data as $row) {
            if ($ids == "") {
                if ($row['from'] == $_REQUEST['id']) {
                    $ids = $row['to'];
                } else {
                    $ids = $row['from'];
                }
            } else {
                if ($row['from'] == $_REQUEST['id']) {
                    $ids .= ", " . $row['to'];
                } else {
                    $ids .= ", " . $row['from'];
                }
            }
        }
         
        $where = "";
        $data= array();
        $data['friends'] = array();
        if ($ids != "") {
            $where = " serverId in ($ids)";
            $data['friends'] = $db->db_select("user", "serverId AS `key`", $where);
        }
        echo json_encode($data);
        break;
    }

    case "friend" :  {
        $db->db_insert("friend");
        break;
    }

    case "edit-friend" :  {

        $hide = $_REQUEST['Hide'];
        $query = "UPDATE friend SET `toHide` = '$hide' WHERE `to` = '". $_REQUEST['FriendId'] ."' AND `from` = '". $_REQUEST['UserId'] ."' ";
        $db->db_query($query);
        $query = "UPDATE friend SET `fromHide` = '$hide' WHERE `from` = '". $_REQUEST['FriendId'] ."' AND `to` = '". $_REQUEST['UserId'] ."' ";
        $db->db_query($query);
        break;
    }

    case "getFutureEvents" :      {
        $res = $db->db_select("events", "*", "creatorId='" . @$_REQUEST['userId'] . "'");
        $data['entities'] = array();
        foreach ($res as $row) {
            $row['dateModified'] = changeTotimezone($row['dateModified']);
            $row['endTime'] = changeTotimezone($row['endTime']);
            $row['startTime'] = changeTotimezone($row['startTime']);
            $row['recurringEndTime'] = changeTotimezone($row['recurringEndTime']);
            $row['dateCreated'] = changeTotimezone($row['dateCreated']);
            $row['creator'] = $row['creatorId'];
            $row['busy'] = $row['isPrivate'];
            $row['locations'][] = array("name" => $row['location']) ;
            unset($row['location']);
            $row['key'] = $row['id'];
            $data['entities'][] = $row;
        }
        $data['statusCode'] = "200";
        echo json_encode($data);
        break;
    }

    case "getGoldEvents" :       {
        $where = "(`from`= '" . $_REQUEST['userId']. "' and `to`= '" . $_REQUEST['CURRENTUSERID']. "' )";
        $where .= " or (`from`= '" . $_REQUEST['CURRENTUSERID'] . "' and `to`= '" . $_REQUEST['userId']. "' )";
        $dd = $db->db_select("friend", "*", $where);
        if(empty($dd) && $_REQUEST['CURRENTUSERID']!=$_REQUEST['userId'] )
        {
            $limit = "";
            if(isset($_REQUEST['limit']))
            {
                $limit = "limit " .$_REQUEST['startwith']  . " , " .$_REQUEST['limit'];
            }
            $res = $db->db_select("events", "GROUP_CONCAT(id) as Ids", "creatorId='" . @$_REQUEST['userId'] . "' AND isOpen='1' and  `isGold`='1'");
            $ids= $res[0]['Ids'];
            $res = $db->db_select("invitation", "GROUP_CONCAT(eventId) as Ids", "touser='" . @$_REQUEST['userId'] . "' and `attending` = '1' and `isGold`='1' AND (`stealth` = 0 OR `fromUser`='{$_REQUEST['CURRENTUSERID']}' )");
            if($ids=="")
            {
                $ids = $res[0]['Ids'];
            }
            else
            {
                if($res[0]['Ids']!="")
                {
                    $ids .= "," . $res[0]['Ids'];
                }
            }
            $res = array();
            if($ids!="")
            {
			    $res = $db->db_select("events", "*", "id in($ids) AND isOpen='1' ORDER BY startTime,endTime DESC");  
            }
            
        }
        else
        {
            $limit = "";
            if(isset($_REQUEST['limit']))
            {
                $limit = "limit " .$_REQUEST['startwith']  . " , " .$_REQUEST['limit'];
            }
            $res = $db->db_select("events", "GROUP_CONCAT(id) as Ids", "creatorId='" . @$_REQUEST['userId'] . "'  and  `isGold`='1'");
            $ids= $res[0]['Ids'];
            //$res = $db->db_select("events", "GROUP_CONCAT(id) as Ids", " `isGold`='1' AND id IN(SELECT eventId FROM invitation WHERE touser='" . @$_REQUEST['CURRENTUSERID'] . "' and fromuser='" . @$_REQUEST['userId'] . "' and  `attending` = '1' )");
            //$IDSOPEN= $res[0]['Ids'];
            
            
            if ($_REQUEST['userId']==$_REQUEST['CURRENTUSERID']) {
            $res = $db->db_select("invitation", "GROUP_CONCAT(eventId) as Ids", "touser='" . @$_REQUEST['userId'] . "' and `attending` = '1' and `isGold`='1'");
            //print_r($res);
 			}   
 			else {
 			 $res = $db->db_select("invitation", "GROUP_CONCAT(eventId) as Ids", "touser='" . @$_REQUEST['userId'] . "' and `attending` = '1' and `isGold`='1' AND (`stealth`= 0 OR `fromUser`='{$_REQUEST['CURRENTUSERID']}' )");
 			}        
            
            if($ids=="")
            {
                $ids = $res[0]['Ids'];
            }
            else
            {
                if($res[0]['Ids']!="")
                {
                    $ids .= "," . $res[0]['Ids'];
                }
            }
            $res = array();
            if($ids!="")
            {
                    $res = $db->db_select("events", "*", "id in($ids) and (isPrivate='0' OR  creatorId='" . @$_REQUEST['CURRENTUSERID'] . "' ) ORDER BY startTime DESC,endTime DESC");  
            }
        }
        
         
        $data['entities'] = array();
        foreach ($res as $row) {
            $row['dateModified'] = changeTotimezone($row['dateModified']);
            $row['endTime'] = changeTotimezone($row['endTime']);
            $row['startTime'] = changeTotimezone($row['startTime']);
            $row['recurringEndTime'] = changeTotimezone($row['recurringEndTime']);
            $row['dateCreated'] = changeTotimezone($row['dateCreated']);
            $row['creator'] = $row['creatorId'];
            $row['busy'] = $row['isPrivate'];
            $row['isGold'] = 1;
            $row['locations'][] = array("name" => $row['location']) ;
            $row['key'] = $row['id'];
            $data['entities'][] = $row;
        }
        $data['statusCode'] = "200";
        echo json_encode($data);
        break;

    }
     
    case "hideFromNewsReal" :    {
        if($_REQUEST['eventIds'])
        {
            $res = $db->db_query("UPDATE events set Hide ='1' where id in(" . @$_REQUEST['eventIds'] . ")");
        }
        break;
    }
     
    case "getFriendship" :       {
            $res = $db->db_select("invitation", "*", "toUser='" . @$_REQUEST['FriendId'] . "' and fromUser='" . @$_REQUEST['userId'] . "' and  `isGold`='1' order by id desc ".$limit);
            $data['totalGoldStarEvents'] = count($res);
             
            $where = "(`from`= '" . $_REQUEST['userId'] . "' and `to`= '" . $_REQUEST['FriendId'] . "' )";
            $where .= " or (`from`= '" . $_REQUEST['FriendId'] . "' and `to`= '" . $_REQUEST['userId'] . "' )";
            $dd = $db->db_select("friend", "*", $where);
            $data['timeStamp'] = get_time_diff1(@$dd[0]['dateCreated']);
             
            $where  = " `type` = 'TymepassEvent' AND ( `toUser` = '". $_REQUEST['userId'] ."' OR  `fromUser` = '". $_REQUEST['userId'] ."' ) AND `attending`=1";
            $res1 = $db->db_select("invitation","eventId", $where);
            $array1 = array();
            foreach ($res1 as $row)
            {
                $array1[$row['eventId']] = $row['eventId'];
            }
            $where  = " `type` = 'TymepassEvent' AND ( `toUser` = '". $_REQUEST['FriendId'] ."' OR  `fromUser` = '". $_REQUEST['FriendId'] ."' )  AND `attending`=1";
            $res2 = $db->db_select("invitation","eventId", $where);
             
            $array2 = array();
            foreach ($res2 as $row)
            {
                $array2[$row['eventId']] = $row['eventId'];
            }
            $i = 0;
            foreach ($array1 as $key => $val)
            {
                if(in_array($val, $array2))
                {
                    $i++;
                }
            }
             
             
             
             
            $where = "(`from`= '" . $data[0]['toUser'] . "' and `to`= '" . $data[0]['fromUser'] . "' )";
            $where .= " or (`from`= '" . $data[0]['fromUser'] . "' and `to`= '" . $data[0]['toUser'] . "' )";
            $dd = $db->db_select("friend", "*", $where);
             
            $data['commonEvent'] = $i;
             
             
             
            echo json_encode($data);
            break;

        }

    case "getStealthFrom" :  {
        $where = "eventId = '" . $_REQUEST['event'] . "' and `toUser`= '" . $_REQUEST['userId'] . "'  and stealth=1";
        $data = $db->db_select("invitation", "`toUser` as `user`", $where);
        $ids = "";
        foreach ($data as $row) {
            if ($ids == "") {
                $ids = $row['user'];
            } else {
                $ids .= "," . $row['user'];
            }
        }
        $id['entities'] = $ids;
        echo json_encode($id);

        break;
    }
 
    case "getEvents" :   {

        $res = "";
        foreach ($_REQUEST['ids'] as $key => $value) {
            if ($res == "") {
                $res =  "'" .$value . "'";
            } else {
                $res .= ",'" . $value . "'";
            }
        }
        if($res!="")
        {
            $event = $db->db_select("events", "*", "id in (" .  $res . ")");
        }
       
        if($_REQUEST['userId']==$_REQUEST['CURRENTUSERID'])
        {
        //removed AND attending=1  from the query below
            $invitation = $db->db_select("invitation", "eventId , attending, isGold", " `type` = 'TymepassEvent' AND `toUser` = '" . @$_REQUEST['userId'] ."' AND (`stealth` = 0 OR `fromUser`='{$_REQUEST['CURRENTUSERID']}' ) AND `eventId` in  (" .  $res . ") ");
        }
        else
        {
        //removed AND attending=1  from the query below
        
            $invitation = $db->db_select("invitation", "eventId , attending, isGold", " `stealth` != '1' AND `type` = 'TymepassEvent' AND `toUser` = '" . @$_REQUEST['userId'] ."' AND (`stealth` = 0 OR `fromUser`='{$_REQUEST['CURRENTUSERID']}' ) AND `eventId` in  (" .  $res . ")");
        }
          
        $ids = array();
        $attending = array();
        $isGold = array();
        

        $data['entities'] = array();
        foreach ($event as $row) {
        
        foreach ($invitation as $invite)
        {
           /* $ids[] = $invite['eventId'];
            $attending['recurring'] = "0";
            $attending[$row['eventId']] = $invite['attending'];
            $isGold[$row['eventId']] = $invite['isGold'];*/
            
            if ($invite['eventId']==$row['id']){
            $row['attending']=$invite['attending'];
            $row['isGold']=$invite['isGold'];
            }
            
        }
        
        
            $row['serverId'] = $row['id'];
            $row['key'] = $row['id'];
            $row['creator'] = $row['creatorId'];
            
           $row['title'] = mb_check_encoding($row['title'], 'UTF-8') ? $row['title'] : utf8_encode($row['title']);
           
           $row['info'] = mb_check_encoding($row['info'], 'UTF-8') ? $row['info'] : utf8_encode($row['info']);
            
            $row['parentServerId'] = $row['perent'];
            if($_REQUEST['userid'] != $row['creatorId'])
            {
                $row['isGold'] = isset($isGold[$row['id']])?$isGold[$row['id']]:"0";
            }

            $row['startTime'] = changeTotimezone($row['startTime']);
            $row['endTime'] = changeTotimezone($row['endTime']);
            $row['recurringEndTime'] = changeTotimezone($row['recurringEndTime']);
            $row['dateModified'] = changeTotimezone($row['dateModified']);
            $row['dateCreated'] = changeTotimezone($row['dateCreated']);
            $row['locations'][] = array("name" => $row['location']) ;
            $row['chield'] =  $db->db_select("events", "id", " perent='".$row['id']  ."'");
            $data['entities'][] = $row;
        }
        echo json_encode($data);
        break;
    }

    case "getFeedback":  {
        $data['cms'] = $db->db_select("cms");                                                                                               
        echo json_encode($data);
        break;         }
    
    case "getAttendees":   {

        $limit = "";
        if(isset($_REQUEST['limit']))
        {
            $limit = "limit " . $_REQUEST['limit'];
        }

        $where = "id = '" . $_REQUEST['id'] . "' $limit";
        $ids = $db->db_select("events", "`creatorId` as `key`", $where);
        if($ids[0]['key'] == $_REQUEST['userId'])
        {
            $where = "`type` = 'TymepassEvent' AND eventId = '" . $_REQUEST['id'] . "' and attending=1 $limit";    
            $data['users'] = $db->db_select("invitation", "`toUser` as `key`", $where);
            $data['users'][] = $ids[0];
        }
        else
        {
            $where = "`type` = 'TymepassEvent' AND eventId = '" . $_REQUEST['id'] . "' and attending=1 AND (`stealth` = 0 OR toUser='" . $_REQUEST['userId']. "' ) $limit";    
            $data['users'] = $db->db_select("invitation", "`toUser` as `key`", $where);
            $data['users'][] = $ids[0];
            
        }
        
        
        echo json_encode($data);
        break;
    }
    
    case "getMaybe":   {

        $limit = "";
        if(isset($_REQUEST['limit']))
        {
            $limit = "limit " . $_REQUEST['limit'];
        }

        $where = "id = '" . $_REQUEST['id'] . "' $limit";
        $ids = $db->db_select("events", "`creatorId` as `key`", $where);
        
         if($ids[0]['key'] == $_REQUEST['userId'])
        {
              $where = "`type` = 'TymepassEvent' AND eventId = '" . $_REQUEST['id'] . "' and attending=2 $limit";
            $data['users'] = $db->db_select("invitation", "`toUser` as `key`", $where);
            echo json_encode($data);
        }
        else
        {
             $where = "`type` = 'TymepassEvent' AND eventId = '" . $_REQUEST['id'] . "' and attending=2 AND (`stealth` = 0 OR toUser='" . $_REQUEST['userId']. "' ) $limit";
            $data['users'] = $db->db_select("invitation", "`toUser` as `key`", $where);
            echo json_encode($data);
            
        }

        
        break;
    }
    
    case "eventAttendeesCount":   {

        $where = "id = '" . $_REQUEST['id'] . "' $limit";
        $ids = $db->db_select("events", "`creatorId` as `key`", $where);
        
         if($ids[0]['key'] == $_REQUEST['userId'])
        { 
                $where = "`type` = 'TymepassEvent' AND eventId = '" . $_REQUEST['id'] . "' and attending= 1";
                $data['users'] = $db->db_select("invitation", "`toUser` as `key`", $where);
                $result['count']  = count( $data['users'])+1;
                
                $where = "`type` = 'TymepassEvent' AND eventId = '" . $_REQUEST['id'] . "' and attending= 2";
                $data['users'] = $db->db_select("invitation", "`toUser` as `key`", $where);
                $result['mybecount']  = count( $data['users']);
        }
        else
        {
               $where = "`type` = 'TymepassEvent' AND eventId = '" . $_REQUEST['id'] . "' and attending= 1 AND (`stealth` = 0 OR toUser='" . $_REQUEST['userId']. "' )";
                $data['users'] = $db->db_select("invitation", "`toUser` as `key`", $where);
                $result['count']  = count( $data['users'])+1;
                
                $where = "`type` = 'TymepassEvent' AND eventId = '" . $_REQUEST['id'] . "' and attending= 2 AND (`stealth` = 0 OR toUser='" . $_REQUEST['userId']. "' )";
                $data['users'] = $db->db_select("invitation", "`toUser` as `key`", $where);
                $result['mybecount']  = count( $data['users']);
            
        }
        

        
        
        
        echo json_encode($result);
        break;
    }

    case "getInvitees":   {
        
        $where = "id = '" . $_REQUEST['id'] . "' $limit";
        $ids = $db->db_select("events", "`creatorId` as `key`", $where);
        if($ids[0]['key'] == $_REQUEST['userId'])
        { 
                $where = "eventId = '" . $_REQUEST['id'] . "' AND `type` = 'TymepassEvent'";
                $data = $db->db_select("invitation", "`toUser` as `key`", $where);
                $result['entities'] = array();
                
                foreach($data as $row)
                {
                    $result['entities'][] = $row['key'];
                }   
        }
        else
        {
                $where = "eventId = '" . $_REQUEST['id'] . "' AND `type` = 'TymepassEvent' AND (`stealth` = 0 OR toUser='" . $_REQUEST['userId']. "' )";
                $data = $db->db_select("invitation", "`toUser` as `key`", $where);
                $result['entities'] = array();
                
                foreach($data as $row)
                {
                    $result['entities'][] = $row['key'];
                }   
            
        }
        
        echo json_encode($result);
        break;
    }
    
    case "emails" :    {

            foreach ($_REQUEST['emails'] as $key => $value) {
                if ($res == "") {
                    $res = "'" . $value . "'";
                } else {
                    $res .= " ,'" . $value . "'";
                }
            }
            $data['emails'] = array();
            if($res != "")
            {
                $data['emails'] = $db->db_select("user", "name, surname, email, serverId as `key`", "email in (" . $res . ")");
            }
            echo json_encode($data);
            break;
        }
        
    case "twitters" : {
        $res = "";
        foreach ($_REQUEST['twitterIds'] as $key => $value) {
            if ($res == "") {
                $res = "'" . $value . "'";
            } else {
                $res .= " ,'" . $value . "'";
            }
        }

        if($res!="")
        {
            $data['emails'] = $db->db_select("user", "name, surname, email, photo, serverId as `key`, twitterId", "twitterId in (" . $res . ")");
        }
        else
        {
            $data['emails'] = array();
        }

        echo json_encode($data);
        break;
    }
         
    case "checkFacebookIds" :{
         
      
        

        $res = "";
        foreach ($_REQUEST['facebookIds'] as $key => $value) {
            if ($res == "") {
                $res = "'" . $value . "'";
            } else {
                $res .= " ,'" . $value . "'";
            }
        }
        if($res!="")
        {
            $data['emails'] = $db->db_select("user", "name, surname, email, photo, serverId as `key`, facebookId", "facebookId in (" . $res . ")");
        }
        else
        {
            $data['emails'] = array();
        }

        echo json_encode($data);
        break;

    }

    case "twitter" :                 {
        $twId = $_REQUEST['twitterId'];
        $data['emails'] = $db->db_select("user", "name, surname, email, serverId as `key`", "twitterId='$twId'");
        echo json_encode($data);
        break;
    }

    case "privateFrom" :  {
        $users = $_REQUEST['users'];
        foreach ($users as $user) {
            $_REQUEST['users'] = $user;
            $db->db_insert("privateForm");
        }
        $data['status'] = 1;
        echo json_encode($data);
        break;

    }
    
    case "invitation" :   {
         
       // mail("ram.r@quantumtechnolabs.com", "Testing Invitation", print_r($_REQUEST, true));
        
        $touser = $_REQUEST['toUsers'];
        $data = $db->db_select("user", "*", "`serverId`= '" . $_REQUEST['fromUser'] . "'");
        $name = $data[0]['name'];
        $email = $data[0]['email'];

        if($_REQUEST['type']=="TymepassEvent" && $_REQUEST['eventId']=="0")
        {
            echo "]";
            exit;
        }

        if($_REQUEST['type']=="FacebookUser")    {
            foreach ($touser as $ke => $row) {
                $fb= $db->db_select("user", "serverId", "`facebookId`= '" . $row . "' ");
                if(!empty($fb))
                {
                    $_REQUEST['toUser'] = $row = $fb[0]['serverId'];
                    if(check_invitation($_REQUEST['toUser'] , $_REQUEST['fromUser'], @$_REQUEST['eventId']))
                    {
                        $db->db_insert("invitation");  
                        send_friendRequest($_REQUEST['fromUser'], $_REQUEST['toUser']);
                    }
                   
                     
                }
            }

        }
        else if($_REQUEST['type']=="EmailUser")     {
            foreach ($touser as $ke => $row)
            {
                send_invitation_mail($name, $row);
            }
        }
        else if($_REQUEST['type']=="TwitterUser")  {
            foreach ($touser as $ke => $row)
            {
                $fb= $db->db_select("user", "serverId", "`twitterId`= '" . $row . "'");
                if(!empty($fb))
                {
                    $_REQUEST['toUser'] = $row = $fb[0]['serverId'];
                    if(check_invitation($_REQUEST['toUser'] , $_REQUEST['fromUser']))
                    {
                        $db->db_insert("invitation"); 
                        send_friendRequest($_REQUEST['fromUser'], $_REQUEST['toUser']);
                    }
                    
                     
                }
            }

        }
        else if($_REQUEST['type']=="TymepassEventNoPush")  {
          $data = array();
          foreach ($_REQUEST['eventIds'] as $row)
          {
              $data[] = $row;
          } 
           
          $_REQUEST['eventIds'] = $data;
          $data=  array(); 
          for($i=0;$i<count($_REQUEST['eventIds']); $i++) {
                for($j=$i;$j<count($_REQUEST['eventIds']); $j++)
                  {
                        if($_REQUEST['eventIds'][$i] < $_REQUEST['eventIds'][$j])
                        {
                            $teml =  $_REQUEST['eventIds'][$i];
                            $_REQUEST['eventIds'][$i] = $_REQUEST['eventIds'][$j];
                            $_REQUEST['eventIds'][$j] = $teml;
                        }
                  }   
          }  
            
          for($i=0;$i<count($_REQUEST['eventIds']); $i++){  
             $_REQUEST['eventId'] = $_REQUEST['eventIds'][$i]; 
             $_REQUEST['type']="TymepassEvent";
             foreach ($touser as  $row)
              {
                    $_REQUEST['toUser'] = $row;
                    if(check_invitation($_REQUEST['toUser'] , $_REQUEST['fromUser'], @$_REQUEST['eventId']))
                    {
                        $db->db_insert("invitation");  
                   }
             }
         }    

        }
        else    {
             
            foreach ($touser as  $row) {
                $_REQUEST['toUser'] = $row;
            }
           
            foreach ($touser as  $row)
            {
                 
                $_REQUEST['toUser'] = $row;
                $_REQUEST['attending'] = 3;
                if(check_invitation($_REQUEST['toUser'] , $_REQUEST['fromUser'], @$_REQUEST['eventId']))
                {
                    $db->db_insert("invitation");
                      if (isset($_REQUEST['eventId']) && ($_REQUEST['eventId'] != "" || $_REQUEST['eventId'] != 0)) {
                            send_inventRequest($_REQUEST['fromUser'], $_REQUEST['toUser'], $_REQUEST['eventId']);
                        } else
                        {
                            send_friendRequest($_REQUEST['fromUser'], $_REQUEST['toUser']);
                        }
                }
            }

             

        }
        break;
    } 
    
    case "editEventView":  {


        $where = "`fromUser`='" . $_REQUEST['userFromId'] . "' and
                `toUser`='" . $_REQUEST['userToId'] . "' and
                        `eventId`='" . $_REQUEST['eventId'] . "'";
        $oldData =  $db->db_select("invitation", "*", $where);
        if(empty($oldData))       {
            $query = " INSERT INTO `invitation`
                    (`toUser`,`fromUser`,`type`,`dateCreated`,`dateAccepted`,`eventId`,`stealth`,`status`,`attending`,`isGold`,`parentId`)
                    VALUES
                    ('" . $_REQUEST['userToId'] . "',
                            '" . $_REQUEST['userFromId'] . "',
                                    'TymepassEvent',
                                    '" . date("Y-m-d H:i:s") . "',
                                            '" . date("Y-m-d H:i:s") . "',
                                                    '" . $_REQUEST['eventId'] . "',
                                                            '" . $_REQUEST['stealth'] . "',
                                                                    '1',
                                                                    '" . $_REQUEST['status'] . "',
                                                                            '" . $_REQUEST['isGold'] . "',
                                                                                    '0')";
            $db->db_query($query);
            
            send_conformEventNotification($_REQUEST['userToId'], $_REQUEST['userFromId'],  $_REQUEST['eventId'], $_REQUEST['status'], $_REQUEST['isGold']);
            
            $data['status'] = "201";
            echo json_encode($data);
            
            
            if ($_REQUEST['stealth']=="") {
            $_REQUEST['stealth']=0;
            }           
            $_REQUEST['fromUser'] =  $_REQUEST['userFromId'];
            $_REQUEST['toUser'] =  $_REQUEST['userToId'];
            $_REQUEST['type'] =     "TymepassEvent";
            $_REQUEST['dateCreated']  =   date("Y-m-d h:i:s");
            $_REQUEST['dateAccepted ']  =   date("Y-m-d h:i:s");
            $_REQUEST['stealth'] =  $_REQUEST['stealth'];
            $_REQUEST['status'] =  1;
            $_REQUEST['attending'] =  $_REQUEST['status'];
            $_REQUEST['parentId'] =   $_REQUEST['eventId'];
            $_REQUEST['isGold'] =   $_REQUEST['isGold'];
            $chields = $db->db_select("events", "id", "perent = '" . $_REQUEST['eventId'] . "'");
            foreach ($chields as $chiedl)
            {
                $_REQUEST['eventId'] =  $chiedl['id'];
            }
        }
        else
        {
            $EventID = $_REQUEST['eventId'];
            $SQL = "UPDATE invitation set `attending` = '" . $_REQUEST['status'] . "', `dateAccepted` = '" . date("Y-m-d H:i:s") . "' , `stealth` = '" . $_REQUEST['stealth'] . "', status='1', `isGold` = '"  . $_REQUEST['isGold'] . "' where
                    `fromUser`='" . $_REQUEST['userFromId'] . "' and
                            `toUser`='" . $_REQUEST['userToId'] . "' and
                                    `eventId`='" . $_REQUEST['eventId'] . "'";
            $att = $_REQUEST['status'];
            $db->db_query($SQL);
            $data['status'] = "201";
            $data['chield'] = $db->db_select("events", "id", "perent = '" . $_REQUEST['eventId'] . "'");

            $SQL = "Delete FROM invitation WHERE
                    `type`='TymepassEvent' and
                    `parentId`='" . $_REQUEST['eventId'] . "' AND
                            `toUser`='" . $_REQUEST['userToId'] . "'";


           
            $oldData[0]['attending']."!=".$_REQUEST['status'];
            
            if($oldData[0]['attending']!=$_REQUEST['status'])
            {
                
                if($_REQUEST['status']==1&&$_REQUEST['isGold']==1)
                {
                    $query = "INSERT INTO invitation (toUser, fromUser, dateCreated, dateAccepted, `type`, eventId, stealth) VALUES('". $_REQUEST['userFromId'] ."', '". $_REQUEST['userToId']."',  '" . date('Y-m-d H:i:s') . "', '" . date('Y-m-d H:i:s') . "','EventRequestAcceptedGold', '". $_REQUEST['eventId'] ."', '". $_REQUEST['stealth'] ."')";
                    $db->db_query($query);
                }
                else if($_REQUEST['status']==1&&$_REQUEST['isGold']==0)
                {
                    $query = "INSERT INTO invitation (toUser, fromUser, dateCreated, dateAccepted, `type`, eventId, stealth) VALUES('". $_REQUEST['userFromId'] ."', '". $_REQUEST['userToId']."',  '" . date('Y-m-d H:i:s') . "', '" . date('Y-m-d H:i:s') . "','EventRequestAccepted', '". $_REQUEST['eventId'] ."', '". $_REQUEST['stealth'] ."')";
                    $db->db_query($query);
                    
                    //Jayesh
                   $where_open = "`id`='" . $_REQUEST['eventId'] . "'";
                    $openData = $db->db_select("events", "*", $where_open);
                   
                    $where_check_open = "`fromUser`='" . $_REQUEST['userToId'] . "' AND `type` = 'OpenEvent' AND `eventId` = '" . $_REQUEST['eventId'] . "'";
                	$open_checkData = $db->db_select("invitation", "*", $where_check_open);
                        
                    if ($openData[0]['isOpen'] == '1' && count($open_checkData) == 0)  
                    {
                       //$query = "INSERT INTO invitation (`fromUser`,`type`, `dateCreated` , `eventId`) VALUES ('" . $_REQUEST['userToId'] . "', 'EventRequestAccepted', '" . date("Y-m-d H:i:s") . "', '" . $_REQUEST['eventId'] . "')";
                    	//$db->db_query($query);
                        send_OpenEventNotificationForFriends($_REQUEST['userToId'], $_REQUEST['eventId'],$_REQUEST['userFromId'],$openData[0]['title']);
                    }
                    
                }
                else if($_REQUEST['status']==2)
                {
                    $query = "INSERT INTO invitation (toUser, fromUser, dateCreated, dateAccepted, `type`, eventId, stealth) VALUES('". $_REQUEST['userFromId'] ."', '". $_REQUEST['userToId']."',  '" . date('Y-m-d H:i:s') . "', '" . date('Y-m-d H:i:s') . "','EventRequestMayBe', '". $_REQUEST['eventId'] ."', '". $_REQUEST['stealth'] ."')";
                    $db->db_query($query);
                    
                }
               /* if($_REQUEST['isGold']==1)
                {
                    makeGOldStar($_REQUEST['userFromId'],$_REQUEST['userToId'],$EventID ,$_REQUEST['isGold']);
                }  */
                send_conformEventNotification($_REQUEST['userToId'], $_REQUEST['userFromId'], $_REQUEST['eventId'], $att, $_REQUEST['isGold']);
               
            }
            else if($_REQUEST['isGold'] != $oldData[0]['isGold'])
            {
                makeGOldStar($_REQUEST['fromUser'],$_REQUEST['toUser'],$EventID ,$_REQUEST['isGold']);
                if($_REQUEST['isGold']==1)
                {
                    send_NotificationtoCreator($_REQUEST['userToId'], $_REQUEST['userFromId'], $_REQUEST['eventId'], $_REQUEST['isGold']);
                }
            }
            unset($data['chield']);
            echo json_encode($data);
        }
        break;
    }
    
    case "changeEventParams" :{
                                                                                                                                   
        $where = "UPDATE events SET  `attending`= '". $_REQUEST['status']."', `isGold` = '". $_REQUEST['isGold']."' WHERE id='" . $_REQUEST['eventId'] . "' "; 
        $db->db_query($where);
        $data = array();
        $data['status'] = "201";
        echo json_encode($data);
       break; 
    }
   
    case "getEventsByDate":   {
        //  @mail("jason@mobispector.com", "Save", print_r($_REQUEST, true));
  
        $where = "`type` = 'TymepassEvent' AND `toUser` = '". $_REQUEST['userId'] ."' AND `attending` in ('1','2') AND (`stealth` = 0 OR `fromUser`='{$_REQUEST['CURRENTUSERID']}' ) ";
        $res1 = $db->db_select("invitation", "eventId", $where);
        $iId  = "";
        foreach($res1 as $row)
        {
            if($iId=="")
            {
                $iId = $row['eventId'];
            }
            else
            {
                $iId .= ", " .$row['eventId'];
            }
        }
        
        if(isset($_REQUEST['dateFrom']) && $_REQUEST['dateFrom']!="" )
        {
            if($iId=="")
            {
                $where = "creatorId = '" . $_REQUEST['userId'] . "' AND endTime between '" . $_REQUEST['dateFrom'] ."' AND '" . $_REQUEST['dateTo'] ."'  ORDER BY startTime,endTime";
            }
            else
            {
                $where = "(creatorId = '" . $_REQUEST['userId'] . "' OR `id` in ($iId) ) AND endTime between '" . $_REQUEST['dateFrom'] ."' AND '" . $_REQUEST['dateTo'] ."' ORDER BY startTime,endTime";
            }
        }
        else
        {
            if($iId=="")
            {
                $where = "creatorId = '" . $_REQUEST['userId'] . "' AND endTime >= CURDATE() ORDER BY startTime,endTime  limit ". $_REQUEST['startwith'] ." , ". $_REQUEST['limit'];
            }
            else
            {
                $where = "(creatorId = '" . $_REQUEST['userId'] . "' OR `id` in ($iId) ) AND endTime >= CURDATE() ORDER BY startTime,endTime  limit ". $_REQUEST['startwith'] ." , ". $_REQUEST['limit'];
            }
        }
        
  /*      
        $res = $db->db_select("invitation", "GROUP_CONCAT(eventId) as Ids", "touser='" . @$_REQUEST['userId'] . "' and `attending` = '1' and `isGold`='1'");   
  */      
        
        $res = $db->db_select("events", "*", $where);
        
        
        
        $data['entities'] = array();
        foreach ($res as $row) {

            $row['serverId'] = $row['id'];
            $row['key'] = $row['id'];
            $row['creator'] = $row['creatorId'];
            // check if the user has been invited to this event, if so then we can get the current attending status.
            if ($row['creator']!=$_REQUEST['userId']) {
                  $ifinvited = $db->db_select("invitation", "attending,isGold,stealth", "eventId = '".$row['serverId']."' and toUser = '".$_REQUEST['userId']."' AND `type`='TymepassEvent'");
                  if (count($ifinvited)>0){
                        $row['attending']=$ifinvited[0]['attending'];
                        $row['isGold'] = $ifinvited[0]['isGold'];
                        $row['stealth'] = $ifinvited[0]['stealth'];
                  }
            }
                // check if the user has been invited to this event, if so then we can get the status of private or busy.
                if ($row['creator'] != $_REQUEST['userId']) {
                    $ifPrivate = $db->db_select("invitation", "attending", "eventId = '" . $row['serverId'] . "' and ((toUser = '" . $_REQUEST['userId'] . "' and fromUser = '" . $_REQUEST['CURRENTUSERID'] . "') OR (toUser = '" . $_REQUEST['CURRENTUSERID'] . "' and fromUser = '" . $_REQUEST['userId'] . "')) AND `type`='TymepassEvent'");
                    if (count($ifPrivate) > 0) {
                        if($ifPrivate[0]['attending'] == 0) {
                            $row['isPrivate'] = 1;
                            }
                        else {
                            $row['isPrivate'] = 0;
                            }
                    }
                }
if ($row['isPrivate']==1) {
$row['title'] = "Busy";
}
            $row['startTime'] = changeTotimezone($row['startTime']);
            $row['recurringEndTime'] = changeTotimezone($row['recurringEndTime']);
            $row['endTime'] = changeTotimezone($row['endTime']);
            $row['dateModified'] = changeTotimezone($row['dateModified']);
            $row['dateCreated'] = changeTotimezone($row['dateCreated']);
            $row['location'] =  $row['location'] ;
            $row['parentServerId'] =  $row['perent'] ;
            $row['confirmed'] = "1";
            $row['attendingStatus'] = "1";
            $row['locations'][] = array("name" => $row['location']) ;
            $data['entities'][] = $row;
        }
        echo json_encode($data);

        break;
    }

    case "editEventICalId":  {

        $SQL = "UPDATE events set `iCalId` = '" . $_REQUEST['iCalId'] . "' where `id`='" . $_REQUEST['eventId'] . "' AND creatorId = '" . $_REQUEST['userFromId'] ."' limit 1";
        $db->db_query($SQL);
        
        $data = $db->db_select("eventicalid", "id", " eventId = '". $_REQUEST['eventId'] ."' AND userToId= '". $_REQUEST['userToId'] ."' limit 1");
        if(empty($data))
        {
            $db->db_insert("eventicalid");    
        }
        else
        {
            $SQL = "UPDATE eventicalid set `iCalId` = '" . $_REQUEST['iCalId'] . "' where eventId = '". $_REQUEST['eventId'] ."' AND userToId= '". $_REQUEST['userToId'] ."' limit 1";
            $db->db_query($SQL);
        }
        
        echo json_encode($data);
        break;
    }

    case "userSettings": {
            $SQL = "UPDATE user set `iCallSync` = '" . $_REQUEST['iCallSync'] . "' where `serverId`='" . $_REQUEST['serverId'] . "'";
            $db->db_query($SQL);
            $data['id'] = 201;
            echo json_encode($data);
            break;
        }
        
    case "newMessageForEvent":   {
        $_REQUEST['dateCreated'] = date("Y-m-d H:i:s");    
        $data = $db->db_insert("message");
        $where = "`eventId`= '" . $_REQUEST['eventId'] . "' AND `type` = 'TymepassEvent'";
        $dataUsers = $db->db_select("invitation", "*", $where);
        $ids = "";
        $i=0;
        foreach ($dataUsers as $row) 
        {
            //mail("mitul@mobispector.com","Test", print_r($row, true));
            if ($row['fromUser'] == $_REQUEST['creatorId']) {
                
                $_REQUEST['toUser'] = $row['toUser'];
                $_REQUEST['fromUser'] = $row['fromUser'];
                $_REQUEST['eventId'] = $_REQUEST['eventId'];
                $_REQUEST['type'] = "Message";
                $_REQUEST['messagesCount'] = "1";
                $where = "`toUser` = '". $row['toUser'] ."' AND `eventId` = '". $row['eventId'] ."' AND `type` = 'Message'";
                $res  = $db->db_select("invitation", "*", $where);
                if(empty($res))
                {
                    $db->db_insert("invitation");    
                }
                else
                {
                    $query = "UPDATE invitation SET `status` ='0' , messagesCount = messagesCount + 1 WHERE $where";
                    $db->db_query($query);
                }
                send_notification($_REQUEST['creatorId'], $row['toUser'], $_REQUEST['eventId'], "New Message From");
            } 
            else if ($row['toUser'] == $_REQUEST['creatorId'])
            {
                
                $_REQUEST['toUser'] = $row['fromUser'];
                $_REQUEST['fromUser'] = $row['toUser'];
                $_REQUEST['eventId'] = $_REQUEST['eventId'];
                $_REQUEST['type'] = "Message";
                $_REQUEST['messagesCount'] = "1";
                                                        
                $where = "`toUser` = '". $row['fromUser'] ."' AND `eventId` = '". $row['eventId'] ."' AND `type` = 'Message'";
                $res  = $db->db_select("invitation", "*", $where);
                if(empty($res))
                { 
                    $db->db_insert("invitation");    
                }
                        else
                {
                    $query = "UPDATE invitation SET `status` ='0' , messagesCount = messagesCount + 1 WHERE $where";
                    $db->db_query($query);
                }
                if($i==0)
                	send_notification($_REQUEST['creatorId'], $row['fromUser'], $_REQUEST['eventId'], "New Event Message");
                $i++;
            }
        }
       
        echo json_encode($dataUsers);
        break;
    }

    case "getMessagesForEvent":      {

        $query = "UPDATE `invitation` SET `status`='1', `messagesCount`='0' WHERE toUser='". $_REQUEST['userId'] ."' AND eventId='". $_REQUEST['id'] ."' AND type='Message'";
        $db->db_query($query);
        $where = "eventId  ='" . $_REQUEST['id'] . "' ORDER By id";
        $res = $db->db_select("message", "message as `content`, eventId as `event`, dateCreated, creatorId as `creator`, id as `key`", $where);
        $data['messages'] = array();
        foreach ($res as $row)
        {
            $row['dateCreated'] = changeTotimezone($row['dateCreated']);
            $data['messages'][] = $row;
        }
        echo json_encode($data);
        break;     
    }
    
    case "readNotifications":{
        
        $query  = "UPDATE invitation SET `status`='1' WHERE  id  ='" . $_REQUEST['invitationId'] . "' and status=0";
        $db->db_query($query);
        break;
    }
    
    case "setInvitationRSVP":{
        
        $eventId = "";
        foreach ($_REQUEST['ids'] as $key => $value) {
            if ($eventId == "") {
                $eventId =  "'" .$value . "'";
            } else {
                $eventId .= ",'" . $value . "'";
            }
        }
        
        $query  = "UPDATE invitation SET `attending`='".$_REQUEST['attending']."' WHERE  `eventId` in (" . $eventId . ") AND `toUser`='".$_REQUEST['CURRENTUSERID']."'";
        $db->db_query($query);
        
        if ($_REQUEST['attending']==1) {
        
        	foreach ($_REQUEST['ids'] as $key => $value) {
             	$invite = $db->db_select("events", "creatorId", "`id`='".$value."' LIMIT 1" );
       			if (count($invite)>0) {
       				$sendpushto = $invite[0]['creatorId'];
                	send_conformEventNotification($_REQUEST['CURRENTUSERID'], $sendpushto,  $value, $_REQUEST['attending'], 0);
            	}
        	}
        }
        
        break;
    }
    
    case "getNotifications":  {
       
        $where = "toUser  ='" . $_REQUEST['id'] . "' and status=0  ORDER By id desc ";
       // $myquery = "UPDATE invitation SET readed=1 WHERE  toUser  ='" . $_REQUEST['id'] . "' " ;
    
        $dd = $db->db_select("invitation", "FromUser as `userKey` , id as `InvitationId`, type as invitationType , status as `InvitationStatus`, eventId, messagesCount", $where);
        $data['invitations'] = array();
    
        foreach ($dd as $row) {
            if ($row['InvitationStatus'] == 0) {
                $row['InvitationStatus'] = "pending";
            }
            if ($row['invitationType'] == "TymepassUser") {
                $row['invitationType'] = "user";
                $data['invitations'][] = $row;  
            }
            else if ($row['invitationType'] == "FacebookUser") {
                $row['invitationType'] = "user";
                $data['invitations'][] = $row;  
            }
            else if ($row['invitationType'] == "TwitterUser") {
                $row['invitationType'] = "user";
                $data['invitations'][] = $row;  
            }
            else if ($row['invitationType'] == "UserRequestAccepted") {
                $row['invitationType'] = "UserRequestAccepted";
                $d = $db->db_select("user", "name , surname, photo ", "serverId='" . $row['userKey'] . "'");
                $row['user'] = @$d[0];
                $data['invitations'][] = $row;  
            }
            else if ($row['invitationType'] == "TymepassEvent") {
                $row['invitationType'] = "event";
                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                foreach ($d as $event) {
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['parentServerId'] = $event['perent'];
                    unset($event['perent']);
                    $event['recurring'] = 0;
                    $event['iCalId'] = iCal($event['id'],$_REQUEST['id'] );
                    $event['userKey'] = $event['creatorId'];
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            } 
            
            else if ($row['invitationType'] == "EventRequestAccepted") {
                $row['invitationType'] = "EventRequestAccepted";
                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                foreach ($d as $event) {
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['parentServerId'] = $event['perent'];
                    unset($event['perent'])  ;
                    $event['userKey'] = $row['userKey'];
                    $event['iCalId'] = iCal($event['id'],$_REQUEST['id'] );
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            }
            else if ($row['invitationType'] == "EventRequestAcceptedGold") {
                $row['invitationType'] = "EventRequestAcceptedGold";
                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                foreach ($d as $event) {
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['parentServerId'] = $event['perent'];
                    unset($event['perent'])  ;
                    $event['userKey'] = $row['userKey'];
                    $event['iCalId'] = iCal($event['id'],$_REQUEST['id'] );
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            }
            else if ($row['invitationType'] == "EventRequestMayBe") {
                $row['invitationType'] = "EventRequestMayBe";
                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                foreach ($d as $event) {
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['parentServerId'] = $event['perent'];
                    unset($event['perent'])  ;
                    $event['recurring'] = 0;
                    $event['iCalId'] = iCal($event['id'],$_REQUEST['id'] );
                    $event['userKey'] = $event['creatorId'];
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            } 
            else if ($row['invitationType'] == "EditEvent") {
                $row['invitationType'] = "EditEvent";
                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                foreach ($d as $event) {
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['parentServerId'] = $event['perent'];
                    unset($event['perent'])  ;
                    $event['iCalId'] = iCal($event['id'],$_REQUEST['id'] );
                    $event['userKey'] = $event['creatorId'];
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            } 
            else if ($row['invitationType'] == "Message") {

                $row['invitationType'] = "message";
                $row['count'] = $row['messagesCount'];//$dCnt[0]['count'];//"1";//$row['count']+$row['messagesCount'];

                $d = $db->db_select("events", "*", "id='" . $row['eventId'] . "'");
                $event = array();
                foreach ($d as $event) {
                  //  $event['count'] = $row['messagesCount'];
                    $event['serverId'] = $event['id'];
                    $event['key'] = $event['id'];
                    $event['creator'] = $event['creatorId'];
                    $event['iCalId'] = iCal($event['id'],$_REQUEST['id'] );
                    $event['userKey'] = $event['creatorId'];
                    $event['startTime'] = changeTotimezone($event['startTime']);
                    $event['recurringEndTime'] = changeTotimezone($event['recurringEndTime']);
                    $event['endTime'] = changeTotimezone($event['endTime']);
                    $event['dateModified'] = changeTotimezone($event['dateModified']);
                    $event['dateCreated'] = changeTotimezone($event['dateCreated']);
                    $event['locations'][] = array("name" => $event['location']) ;
                    $row['event'] = $event;
                    $data['invitations'][] = $row;  
                }
            }                                       
        }
        $where = "toUser  ='" . $_REQUEST['id'] . "' and status=0  ORDER By id desc ";
        $myquery = "UPDATE invitation SET readed=1 WHERE  toUser  ='" . $_REQUEST['id'] . "' " ;
        $db->db_query($myquery);
        echo json_encode($data);
        break;
    }
  
    case "getUserNotifications":    {

            $userprofileid=$_REQUEST['id'];
            
        $_POST['needImage'] = "No";
            $result = array();
            
            
            
            //get list of friend ids
            
            $where = "(`from`= '" . $_REQUEST['id'] . "' AND `toHide` = '0'  )  OR  (`to` = '" . $_REQUEST['id'] . "' AND `fromHide` = '0' )";
            $data = $db->db_select("friend", "*", $where);
            $ids = "";
            foreach ($data as $row) {
                if ($ids == "") {
                    if ($row['from'] == $_REQUEST['id']) {
                        $ids = $row['to'];
                    } else {
                        $ids = $row['from'];
                    }
                } else {
                    if ($row['from'] == $_REQUEST['id']) {
                        $ids .= ", " . $row['to'];
                    } else {
                        $ids .= ", " . $row['from'];
                    }
                }
            }
            
          //  $ids = $_REQUEST['id'];
           // $_REQUEST['id']=$_REQUEST['CURRENTUSERID'];
            
            
            
         
         
          /*  $where = "`type` = 'TymepassUser' AND `fromUser` ='" . $_REQUEST['id'] . "' AND `status` = '1'";
            $friends = $db->db_select("invitation", "id , toUser, type, fromUser,  dateAccepted as dateCreated ", $where);
            foreach($friends as $row)
            {
                $where =  "`serverId` = '". $row['toUser'] ."'";
                $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                $row['type'] = "FriendRequestAccepted";
                $result['news'][] = $row;
            }*/
            
            // for getting friend open event
			//$where = "`type` = 'TymepassEvent' AND `fromUser`='" . $_REQUEST['id'] . "'  AND `eventId` != 0 AND `stealth`!=1 AND status= 0";
			$where = "`type` = 'TymepassEvent' AND `fromUser`='" . $_REQUEST['id'] . "'  AND `eventId` != 0 AND `stealth`!=1 AND status= 0 GROUP BY eventId";
            $friends = $db->db_select("invitation", "*", $where);
            $eventIds  = "";
            foreach($friends as $row)
            {
                if($row['attending']==3)
                {
                    $eventIds .= "," . $row['eventId'];
                    $row['type'] = "OpenEvent";
                }                                         
                $where =  "`id` = '". $row['eventId'] ."' AND `isPrivate`!=1";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                $row['type'] = "OpenEvent";
                if(!empty($row['eventInfo']))
                {
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
           
            } 
$ids = $_REQUEST['id'];
            $_REQUEST['id']=$_REQUEST['CURRENTUSERID'];
            
 $where = "`type` = 'EventRequestAccepted' AND  `toUser` ='$ids' AND `stealth`!=1 AND `eventId` != 0 GROUP BY eventId";
           
           // $where = "`type` = 'EventRequestAccepted' AND  `toUser` ='$ids' AND `fromUser`!='" . $_REQUEST['id'] . "'  AND `eventId` != 0";
            //$where = "`type` = 'EventRequestAccepted' AND ((`toUser` ='" . $_REQUEST['id'] . "' OR `toUser` in($ids)) OR (`type` = 'OpenEvent' AND `toUser` in($ids)) ) AND `fromUser`!='" . $_REQUEST['id'] . "'  AND eventId != 0 GROUP BY eventId";
           // $where = "((`type` = 'EventRequestAccepted' AND (`toUser` ='" . $_REQUEST['id'] . "' OR `toUser` in($ids))) OR (`type` = 'OpenEvent' AND `toUser` in($ids))) AND `fromUser`!='" . $_REQUEST['id'] . "'  AND `eventId`!='0'";
            $friends = $db->db_select("invitation", "*", $where);
            $eventIds  = "";
            foreach($friends as $row)
            {
                
                $row['fromUser']=$row['toUser'];
                if($row['attending']==1)
                {
                    $eventIds .= "," . $row['eventId'];
                    $row['type'] = "EventRequestAccepted";
                }                                         
                $where =  "`id` = '". $row['eventId'] ."' AND `isPrivate`!=1  AND toUser = '$ids'";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                $row['type'] = "EventRequestAccepted";
                
                if(!empty($row['eventInfo']))
                {
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
           
            } 
            $eventIds="";
            
            /*$where = "`type` = 'EventRequestMayBe' AND `toUser` ='" . $_REQUEST['id'] . "' AND eventId != 0";
            $friends = $db->db_select("invitation", "*", $where);
            $eventIds  = "";
            foreach($friends as $row)
            {
                $row['type'] = "EventRequestMayBe";
                $where =  "`id` = '". $row['eventId'] ."'";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                if(!empty($row['eventInfo']))
                {
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
           
            }*/
            // Fetch Message List
            $where = " `creatorId` ='$ids'";
            $friends = $db->db_select("events", "id", $where);
            foreach($friends as $row)
            {
                $eventIds .= "," . $row['id'];
            }
            if($eventIds !="")
            {
                $eventIds = trim($eventIds, ",");
                $where = "`type` = 'Message' AND eventId in ($eventIds)";
                $friends = $db->db_select("invitation", "*", $where);
                foreach($friends as $row)
                {
                    $where =  "`id` = '". $row['eventId'] ."' and toUser = '$ids'";
                    $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                    $row['type'] = "EventMessage";
                    if(!empty($row['eventInfo']))
                    {
                        $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                        $result['news'][] = $row;
                    }
                }
            }
            $eventIds="";
            // Fetch Gold Star  List
            $where = "`type` = 'TymepassEvent' AND `toUser` ='$ids' AND isGold='1' AND eventId != 0";
            $friends = $db->db_select("invitation", "*", $where);
            $eventIds  = "";
            foreach($friends as $row)
            {
                if($row['attending']==1)
                {
                    $eventIds .= "," . $row['eventId'];
                }
                $where =  "`id` = '". $row['eventId'] ."' AND `isPrivate`!=1  AND toUser = '$ids'";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                $row['type'] = "GoldEvent";
                if(!empty($row['eventInfo']))
                {
                    $row['fromUser']=$ids;
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
            }
             
            $eventIds="";
             
            // For the User Event Create
             
            
            $res = array();
            $where = "";
            if ($ids != "") {
                $where = "creatorId in ($ids) AND Hide='0' AND `perent`=0 and `isPrivate` = 0  and startTime > DATE(NOW()) order by dateModified  limit 50";
                $res = $db->db_select("events", "*", $where);
            }
            $EventIds = "";
            foreach ($res as $row) {
                $row["eventId"] = $row['id'];
                $EventIds .= $row['id'] . ",";
                $row["userId"] = $row['creatorId'];
                $row["eventTitle"] = $row['title'];
                $row["eventStartTime"] = changeTotimezone($row['startTime']);
                $row["recurringEndTime"] = changeTotimezone($row['recurringEndTime']);
                $row["type"] = "event";
                unset($row['photo']);
                $row["eventOpen"] = 0;
                if($ids != $row['creatorId'] )
                {
                    $where = '`toUser` = "$ids" AND  `attending` = 1 AND `eventId` = "' .$row['id'] . '"';
                    $d = $db->db_select("invitation", "toUser", $where);
                    if(empty($d)){
                        $row["attending"] = 0;
                    }   else {
                        $row["attending"] = 1;
                    }
                }
                $row["relationshipCreateDate"] = "";
                //  $result['news'][] = $row;
            }

            #PROFILE EMAGE CHANEG PROFILE IMAGE
            //  echo $ids;
            if($ids!="")
            {
                $where = "`type` = 'UserPicture' AND `fromUser` in($ids)";
                $friends = $db->db_select("invitation", "*", $where);
                foreach($friends as $row)
                {
                    $where =  "`serverId` = '". $row['fromUser'] ."'";
                    $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                    $row['type'] = "UserPicture";
                    $result['news'][] = $row;

                }
                 
            }
            if($EventIds!="")
            {
                $EventIds = $EventIds . "0";
                $where = "`type` = 'profilePick' AND `eventId` in($EventIds)";
                $friends = $db->db_select("invitation", "*", $where);
                foreach($friends as $row)
                {
                    $where =  "`id` = '". $row['eventId'] ."'";
                    $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $row['type'] = "EventPicture";
                    $result['news'][] = $row;

                }
                 
            }
             
               //X is friends with Y (X is a friend of mine, Y can be anyone).
       
            // friends Requests
            if($ids !="")
            {
               // $where = "(`type` = 'TymepassUser' OR `type` = 'FacebookUser' OR `type`='TwitterUser') AND ( `fromUser` in($ids) OR `toUser` in($ids) ) AND `fromUser` != '". $_REQUEST['id'] ."' AND `toUser` != '". $_REQUEST['id'] ."'  AND `status` = '1'";
                $where = "(`type` = 'TymepassUser' OR `type` = 'FacebookUser' OR `type`='TwitterUser') AND ( `fromUser` ='$ids' OR `toUser`='$ids' )  AND `status` = '1'";
               
                $friends = $db->db_select("invitation", "id , toUser, type, fromUser,  dateAccepted as dateCreated ", $where);
                foreach($friends as $row)
                {
                    //qtm change 9-8-13
                    if($ids == $row['toUser']){
                        $where =  "`serverId` = '". $row['fromUser'] ."'";
                        $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);

                        $where =  "`serverId` = '". $row['toUser'] ."'";
                        $row['userInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);

                    }else{
                        $where =  "`serverId` = '". $row['toUser'] ."'";
                        $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);

                        $where =  "`serverId` = '". $row['fromUser'] ."'";
                        $row['userInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                    }
                    // $photoz=$row['friendInfo'][0]['photo'];
                    // $row['friendInfo'][0]['photo']=$row['userInfo'][0]['photo'];
                    //$row['userInfo'][0]['photo']=$photoz;
                    
                    if ($row['toUser']==$userprofileid) {
                    $row['changed']='yes '.$row['toUser'];
                     $test['userInfo']=$row['userInfo'];
                      $test['friendInfo']=$row['friendInfo'];
                    $test['toUser']=$row['toUser'];
                    $test['fromUser']=$row['fromUser'];
                    
                     //$row="";
                     $row['toUser']=$test['fromUser'];
                     $row['fromUser']=$test['toUser'];
                    // $row['userInfo']=$test['friendInfo'];
                    // $row['friendInfo']=$test['userInfo'];
                     }
                    $row['type'] = "UserFriends";
                    $result['news'][] = $row;

                }
            }
             
             

            for($i=0; $i<count($result['news']);$i++)
            {
                for($j=$i; $j<count($result['news']);$j++)
                {
                    if($result['news'][$i]['dateCreated'] < $result['news'][$j]['dateCreated'] )
                    {
                        $temp = $result['news'][$i];
                        $result['news'][$i] = $result['news'][$j];
                        $result['news'][$j] = $temp;
                    }
                }
            }
             
             
            echo json_encode($result);
            break;
        
            
            //this is the old one 
           /* $result['news'] = array();
            $where = "`type` = 'TymepassUser' AND `fromUser` ='" . $_REQUEST['id'] . "'";
            $friends = $db->db_select("invitation", "id , toUser, type, fromUser,  dateAccepted as dateCreated ", $where);
            foreach($friends as $row)
            {
                $where =  "`serverId` = '". $row['toUser'] ."'";
                $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                $row['type'] = "FriendRequestAccepted";
                $result['news'][] = $row;
            }

             
            // EVENT REQUEST ACCEPTED
            $where = "`type` = 'TymepassEvent' AND `fromUser` ='" . $_REQUEST['id'] . "' AND `attending` = '1'";
            $friends = $db->db_select("invitation", "id , toUser, type, fromUser,  dateAccepted as dateCreated ", $where);
            foreach($friends as $row)
            {
                $where =  "`id` = '". $row['eventId'] ."'";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                $row['type'] = "EventRequestAccepted";
                if(!empty($row['eventInfo']))
                {
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
                 
            }
             
             
            // Fetch Gold Star  List
            $where = "`type` = 'TymepassEvent' AND `toUser` ='" . $_REQUEST['id'] . "' AND isGold='1' AND eventId != 0";
            $friends = $db->db_select("invitation", "*", $where);
            $eventIds  = "";
            foreach($friends as $row)
            {
                if($row['attending']==1)
                {
                    $eventIds .= "," . $row['eventId'];
                }
                $where =  "`id` = '". $row['eventId'] ."'";
                $row['eventInfo'] = $db->db_select("events", "title, startTime, creatorId, photo", $where);
                $row['type'] = "GoldEvent";
                if(!empty($row['eventInfo']))
                {
                    $row['eventInfo'][0]['eventStartTime'] = changeTotimezone($row['eventInfo'][0]['startTime']);
                    $result['news'][] = $row;
                }
            }
             
           
            $where = "`type` = 'UserPicture' AND `fromUser` in(". $_REQUEST['id'] .")";
            $friends = $db->db_select("invitation", "*", $where);
            foreach($friends as $row)
            {
                $where =  "`serverId` = '". $row['fromUser'] ."'";
                $row['friendInfo'] = $db->db_select("user", "serverId, name, surname, photo", $where);
                $row['type'] = "UserPicture";
                $result['news'][] = $row;

            }

            for($i=0; $i<count($result['news']);$i++)
            {
                for($j=$i; $j<count($result['news']);$j++)
                {
                    if($result['news'][$i]['dateCreated'] < $result['news'][$j]['dateCreated'] )
                    {
                        $temp = $result['news'][$i];
                        $result['news'][$i] = $result['news'][$j];
                        $result['news'][$j] = $temp;
                    }
                }
            }
             
             
            echo json_encode($result);


            break;*/
        }

    case "sendPasswordrecovery": {
    
    $req = array_merge($_GET, $_POST);
    
        $where = "email='". $_REQUEST['email'] ."'";
        $res = $db->db_select("user","*", $where);
        if(empty($res))
        {
            $data1['user']['error'] = "Enter Valid Email Address";
//$data1['user']['email']=$req['email'];
echo json_encode($data1);
           // exit;
        }
        else
        {
//$emailpassword=mysql_fetch_row($res);
//$data1['user']['email']=$req['email'];
            send_mail_password($_REQUEST['email']);
$data1['user']['success'] = "Please check you registerd mail address";
	
            echo json_encode($data1);
        }
        break;
    }

    case "newMessageForUser":   {
        $data1 = $db->db_insert("chatting");
        $where = "(`from`= '" . $_REQUEST['toUser'] . "' and `to`= '" . $_REQUEST['fromUser'] . "' )";
        $where .= " or (`from`= '" . $_REQUEST['fromUser'] . "' and `to`= '" . $_REQUEST['toUser'] . "')";
        
        $query = "UPDATE friend SET dateUpdated = '" . date("Y-m-d H:i:s") . "'WHERE $where";
        $db->db_query($query);
        sendChattingNotification();
        echo json_encode($data1);
        break;
    }

    case "get-chat":  {
       // $_POST['needImage'] = 'No';
        $where = "(`toUser`= '" . $_REQUEST['toUser'] . "' and `fromUser`= '" . $_REQUEST['fromUser'] . "' )";
        $where .= " or (`toUser`= '" . $_REQUEST['fromUser'] . "' and `fromUser`= '" . $_REQUEST['toUser'] . "') ORDER BY dateCreated desc ";
        $dd = $db->db_select("chatting", "*", $where);
        $data['message'] = array();
        foreach ($dd as $row)
        {

            $data['message'][] = $row;
        }
        $where = "UPDATE chatting set `read`='1'  where  `toUser`= '" . $_REQUEST['fromUser'] . "' and `fromUser`= '" . $_REQUEST['toUser'] . "'";
        $db->db_query($where);
        echo json_encode($data);
        break;
    }

    case "chat-count":  {
        $where = "`toUser`= '" . $_REQUEST['id'] . "' and `read` = '0'";
        $dd = $db->db_select("chatting", "*", $where);
        $data['message'] = count($dd);
        echo json_encode($data);

        break;
    }

    case 'image':{
        if (isset($_FILES['imageField'])) {
            $path = $_REQUEST['imagePath'];
            $filename = time() . "_" . $_FILES['imageField']['name'];
            $arr2["fileName"] = $filename;
            $arr2["Status"] = true;

            $img_name = $_FILES['imageField']['name'];
            $system = explode(".", $img_name);
            $flg = 0;
            if (preg_match("/jpg|jpeg|JPG|JPEG/", $system[1]))
                $flg = 1;
            if ($flg == 0) {
                if (preg_match("/gif|GIF/", $system[1]))
                    $flg = 1;
            }
            if ($flg == 0) {
                if (preg_match("/png|PNG/", $system[1]))
                    $flg = 1;
            }
            if ($flg == 1) {
                $destination = "upload/";
                $destination = "upload/original/";
                $file_path = $destination . $filename;
                if (!is_writable($destination)) {
                    @chmod($destination, 0777);
                }
                if (move_uploaded_file($_FILES['imageField']['tmp_name'], $file_path)) {
                    $destination = "images/thumb/";
                    $file_path = $destination . $filename;
                    if (!is_writable($destination)) {
                        @chmod($destination, 0777);
                    }

                    $arr2["fileName"] = $filename;
                    $arr2["Status"] = true;
                }
            } else {
                $error = "Problem with file upload";
                $arr2["fileName"] = "0";
                $arr2["Status"] = $error;
            }
        } else {
            $arr2["Status"] = "dont know what i do got here ";
        }
        echo str_replace('\"', '', str_replace("\/", "/", json_encode($arr2)));

        break;
    }

    case "pendingEventCount":  {
        $where = "`toUser` = '" . $_REQUEST['id'] . "' AND `type` = 'TymepassEvent' AND `attending` in (0,3) ";
        $dat = $db->db_select("invitation", "eventId", $where);
        $count = 0;
        
        foreach($dat as $row)
        {
            $where = "startTime >= DATE(NOW()) AND id = '" . $row['eventId'] . "'";
            $dd = $db->db_select("events", "id , isOpen", $where);
            if(!empty($dd))
            {   
                if($dd[0]['isOpen'] == 0 )
                {
                    $count++;    
                }            
            }
        }   
        $data['count'] = $count;
        echo json_encode($data);
        break;

    }
   
    case "syncNewEvent": {
           $data = $_REQUEST['syncData'];
           $res = array();
           foreach ($data as $row)
           {
                    $_REQUEST = (array)$row;
                    $response = array();
                    $response['iCalId'] = $_REQUEST['iCalId'];
                    $response['Response'] = NewEvents();    
                    $res[] = $response;
           }
           echo json_encode($res);
           break;
           exit;
    } 
    
    case "syncEditEventICalId": {
        
           $data = $_REQUEST['syncData'];
           $res = array();
           foreach ($data as $row)
           {
                    $_REQUEST = (array)$row;
                    $response = array();
                    $response['iCalId'] = $_REQUEST['iCalId'];
                    $response['Response'] = NewChangeIcall();    
                    $res[] = $response;
           }
           echo json_encode($res);
           break;
           exit;
    } 
    
    default: {
        $data1['error'] = "Invalid Action";
        $data1['response'] = $_REQUEST;
        echo json_encode($data1);
        break;
    }
}

echo "]";

function makeGOldStar($CreateorID, $UserID, $EventId, $isGold) {
    $db = new db_class();

    if($isGold==1)
    {
        $_REQUEST['CreatorId'] = $CreateorID;
        $_REQUEST['UserId'] = $UserID;
        $_REQUEST['EventId'] = $EventId;
        $_REQUEST['dateCreated'] = date("Y-m-d H:i");
        $db->db_insert("goldStarNotification");
        
        $where = "serverId = '$UserID'";
        $data = $db->db_select("user", "name", $where);
        $UserName = $data[0]['name'];

        $where = "serverId = '$CreateorID'";
        $data = $db->db_select("user", "deviceId", $where);
        $deviceId = $data[0]['deviceId'];

        $where = "id = '$EventId'";
        $data = $db->db_select("events", "title", $where);
        $eventTitle = $data[0]['title'];
        $msg = "$UserName has make gold star event '$eventTitle'";
        sendMessageToPhone($deviceId, $msg, "GoldEvent" , $EventId);   
        
    }
    else
    {
        $query = "DELETE FROM `goldStarNotification` WHERE `CreatorId`='$CreateorID' AND `UserId` ='$UserID' AND `EventId`='$EventId'";
        $db->db_query($query);
    }
}

function send_mail($data) {
    $to = $_REQUEST['vEmail'];
    $subject = 'Password Reset';

    // message
    $message = '
            <html>
            <head>
            <title>TymePass Server</title>
            </head>
            <body>
            <p>TymePass Password Reset</p>
            <table>
            <tr>
            <td>Name</td>
            <td>' . $data[0]['Name'] . '</td>
                    </tr>
                    <tr>
                    <td>Email ID</td><td>' . $data[0]['Email'] . '</td>
                            </tr>
                            <tr>
                            <td>Password</td><td>' . $data[0]['Password'] . '</td>
                                    </tr>
                                    </table>
                                    </body>
                                    </html>
                                    ';

    // To send HTML mail, the Content-type header must be set
    $headers = 'MIME-Version: 1.0' . "\r\n";
    $headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";
    // Additional headers
    $headers .= 'From: Admin <info@tymepass.com>' . "\r\n";
    // Mail it
    //     echo $message;
    @mail($to, $subject, $message, $headers);
}

function send_invitation_mail( $name, $to) {
    $subject = 'Invitation to Tymepass ';
    $message = '
            <html>
            <head>
            <title>Tymepass Server</title>
            </head>
            <body>
            Email : - ' . $to . '<br />
                    So, just say ' . $name . ' would like to invite to you Join Tymepass..<br />
                            Click here to download the app..<br />
                            </body>
                            </html>
                            ';
    $headers = 'MIME-Version: 1.0' . "\r\n";
    $headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";
    $headers .= 'From: Admin <info@tymepass.com>' . "\r\n";
    @mail($to, $subject, $message, $headers);
}

function send_notification($uid, $friendId, $eventId, $type) {

    $db = new db_class();
    $where = "serverId = '$uid'";
    $data = $db->db_select("user", "name", $where);
    $UserName = $data[0]['name'];

    $where = "serverId = '$friendId'";
    $data = $db->db_select("user", "deviceId", $where);
    $deviceId = $data[0]['deviceId'];

    $where = "id = '$eventId'";
    $data = $db->db_select("events", "title", $where);
    $eventTitle = $data[0]['title'];
    $msg = "$UserName has posted a message in $eventTitle";
    sendMessageToPhone($deviceId, $msg, "Message" , $eventId);
}

function send_friendRequest($uid, $friendId) {
    $db = new db_class();
    $where = "serverId = '$uid'";
    $data = $db->db_select("user", "name", $where);
    $UserName = $data[0]['name'];

    $where = "serverId = '$friendId'";
    $data = $db->db_select("user", "deviceId", $where);
    $deviceId = $data[0]['deviceId'];

    $msg = "$UserName would like to Tymepass with you";

    sendMessageToPhone($deviceId, $msg, "FriendRequest", $uid);
}

function send_inventRequest($uid, $friendId, $event_id) {
    $db = new db_class();
    $where = "serverId = '$uid'";
    $data = $db->db_select("user", "name", $where);
    $UserName = $data[0]['name'];

    $where = "serverId = '$friendId'";
    $data = $db->db_select("user", "deviceId", $where);
    $deviceId = $data[0]['deviceId'];

    $where = "id = '$event_id'";
    $data = $db->db_select("events", "title", $where);
    $eventTitle = $data[0]['title'];
    $msg = "$UserName would like to invite you to $eventTitle";
    sendMessageToPhone($deviceId, $msg, "EventInvitation", $event_id);
}

function send_conformEventNotification($uid, $friendId, $event_id, $status, $gold) {
    $db = new db_class();
    $where = "serverId = '$uid'";
    $data = $db->db_select("user", "name", $where);
    $UserName = $data[0]['name'];

    $where = "serverId = '$friendId'";
    $data = $db->db_select("user", "deviceId", $where);
    $deviceId = $data[0]['deviceId'];

    $where = "id = '$event_id'";
    $data = $db->db_select("events", "title", $where);
    $eventTitle = $data[0]['title'];
    if ($status == 1) {
        if($gold==1)
        {
            $msg = "$UserName has accepted and goldstarred $eventTitle";
        }
        else
        {
            $msg = "$UserName has accepted your invitation to $eventTitle";    
        }
        
        sendMessageToPhone($deviceId, $msg, "EventInvitationConfirm", $event_id);
    } else if ($status == 2) {
        if($gold==1)
        {
            $msg = "$UserName is a maybe and gold starred $eventTitle";
        }
        else
        {
            $msg = "$UserName is a maybe for $eventTitle";    
        }
        
        sendMessageToPhone($deviceId, $msg, "EventInvitationMaybe", $event_id);
    }else {
        /*$msg = "$UserName is a decline for the event '$eventTitle'";
        sendMessageToPhone($deviceId, $msg, "EventInvitationMaybe", $event_id);*/
    }
}

function send_NotificationtoCreator($uid, $friendId, $event_id, $status) {
    $db = new db_class();
    $where = "serverId = '$uid'";
    $data = $db->db_select("user", "name", $where);
    $UserName = $data[0]['name'];

    $where = "serverId = '$friendId'";
    $data = $db->db_select("user", "deviceId", $where);
    $deviceId = $data[0]['deviceId'];

    $where = "id = '$event_id'";
    $data = $db->db_select("events", "title", $where);
    $eventTitle = $data[0]['title'];
    if ($status == 1) {
        $msg = "$UserName has goldstarred $eventTitle";
        sendMessageToPhone($deviceId, $msg, "EventInvitationConfirm", $event_id);
    } else {
        $msg = "$UserName has ungoldstarred $eventTitle";
        sendMessageToPhone($deviceId, $msg, "EventInvitationMaybe", $event_id);
    }
}

function send_EventEditNotification($event_id) {
    $db = new db_class();

    $where = "id = '$event_id'";
    $data = $db->db_select("events", "creatorId, title", $where);
    $eventTitle = $data[0]['title'];
    $created = $data[0]['creatorId'];


    $where = "serverId = '$created'";
    $data = $db->db_select("user", "name", $where);
    $UserName = $data[0]['name'];

    $where = "eventId = '$event_id' and `fromUser`= '" . $created. "' and `type`='TymepassEvent' AND (`attending`=1 OR `attending`=2)";
    $ids  = "";
    $data = $db->db_select("invitation", "`toUser`", $where);


    foreach($data as $row){
        if($ids=="")
        {
            $ids = $row['toUser'];
        }
        else
        {
            $ids .= ", ". $row['toUser'];
        }

    }
     
    if ($ids != "") {
        $where = "`serverId` in(" . $ids . ")";
        $data = $db->db_select("user", "serverId , deviceId", $where);
        $msg = "$UserName has made changes to $eventTitle";
        
        foreach ($data as $row)
        {
        
             $_REQUEST['toUser'] = $row['serverId'];
             $_REQUEST['fromUser'] = $created;     
             $_REQUEST['type'] = "EditEvent";
             $_REQUEST['dateCreated'] = date("Y-m-d H:i:s");
             $_REQUEST['dateAccepted'] = date("Y-m-d H:i:s");
             $_REQUEST['eventId'] = $event_id;
             $db->db_insert("invitation");
        
        
            if($row['deviceId'] !="00000000")
            {
                sendMessageToPhone($row['deviceId'], $msg, "Event", $event_id);
            }
             
        }

  }
}

function send_OpenEventNotification($userId, $eventId, $chields = array()) {
    $db = new db_class();

    $where = "serverId = '$userId'";
    $data = $db->db_select("user", "name", $where);
    $UserName = $data[0]['name'];

    $where = "`to` = $userId or `from` = $userId ";
    $data1 = $db->db_select("friend", "*", $where);

    $ids = "";
    foreach($data1 as $row){
        if($ids=="")
        {
            if($userId==$row['from'])
            {
                $ids = $row['to'];
            }
            else
            {
                $ids = $row['from'];
            }
             
        }
        else
        {
            if($userId==$row['from'])
            {
                $ids .= ",". $row['to'];
            }
            else
            {
                $ids .= ",". $row['from'];
            }
        }

    }

    $msg = "$UserName has created an open event '" . $_REQUEST['title']."'";
     
    if ($ids != "") {
        $where = "`serverId` in(" . $ids . ") AND `serverId` != '$userId'";
        $data = $db->db_select("user", "serverId, deviceId", $where);
        $deviceId = "";

// invite for all the child events
        for($i=count($chields)-1;$i>=0; $i-- )
        {      
                foreach ($data as $row) {
                
                // check if the user has already been invited to the event, if they have, then skip the invite, if they haven't then send a new invite.
                $checkIfInvited = $db->db_select("invitation","*","`toUser`='".$row['serverId']."' AND `fromUser`='".$userId."' AND `eventId`='".$chields[$i]['id']."' AND `type`='TymepassEvent'");
                if (count($checkIfInvited)==0) {
                $_REQUEST['toUser'] = $row['serverId'];
                    $_REQUEST['fromUser'] = $userId;
                    $_REQUEST['eventId'] = $chields[$i]['id'];
                    $_REQUEST['type'] = "TymepassEvent"; 
                    $_REQUEST['attending'] = "3"; 
                    $db->db_insert("invitation");
                    }
                   //z` ` @sendMessageToPhone($row['deviceId'], $msg, "Event", $eventId);
                }
        }
        
        //invite for the master event
        // check if the user has already been invited to the event, if they have, then skip the invite, if they haven't then send a new invite.
        $checkIfInvited = $db->db_select("invitation","*","`toUser`='".$row['serverId']."' AND `fromUser`='".$userId."' AND `eventId`='".$eventId."' AND `type`='TymepassEvent'");
        if (count($checkIfInvited)==0) {
         
        	foreach ($data as $row) {
            	$_REQUEST['toUser'] = $row['serverId'];
            	$_REQUEST['fromUser'] = $userId;
            	$_REQUEST['eventId'] = $eventId;
            	$_REQUEST['type'] = "TymepassEvent"; 
            	$_REQUEST['attending'] = "3"; 
            	$db->db_insert("invitation");
            	@sendMessageToPhone($row['deviceId'], $msg, "Event", $eventId);
            }
        }
    }
}
// qtm changes 8-8-13
function send_OpenEventNotificationForFriends($userId, $eventId, $creatorId,$title) {
    $db = new db_class();

    $where = "serverId = '$userId'";
    $data = $db->db_select("user", "name", $where);
    $UserName = $data[0]['name'];

    $where = "(`to` = $userId or `from` = $userId ) AND `to` != $creatorId and `from` != $creatorId ";
    $data1 = $db->db_select("friend", "*", $where);

    $ids = "";
    foreach($data1 as $row){
        if($ids=="")
        {
            if($userId==$row['from'])
            {
                $ids = $row['to'];
            }
            else
            {
                $ids = $row['from'];
            }
             
        }
        else
        {
            if($userId==$row['from'])
            {
                $ids .= ",". $row['to'];
            }
            else
            {
                $ids .= ",". $row['from'];
            }
        }

    }
	//13-9-13 qtm change
    //$msg = "$UserName has invited you to the open event '" . $_REQUEST['title']."'";
    $msg = "$UserName  is attending the open event '" . $title . "'. Would you like to attend?";
     
    if ($ids != "") {
        $where = "`serverId` in(" . $ids . ") AND `serverId` != '$userId'";
        $data = $db->db_select("user", "serverId, deviceId", $where);
        $deviceId = "";

        
        //invite for the master event
        // check if the user has already been invited to the event, if they have, then skip the invite, if they haven't then send a new invite.
        $checkIfInvited = $db->db_select("invitation","*","`toUser`='".$row['serverId']."' AND `fromUser`='".$userId."' AND `eventId`='".$eventId."' AND `type`='TymepassEvent'");
        if (count($checkIfInvited)==0) {
         
        	foreach ($data as $row) {
            	$_REQUEST['toUser'] = $row['serverId'];
            	$_REQUEST['fromUser'] = $userId;
            	$_REQUEST['eventId'] = $eventId;
            	$_REQUEST['type'] = "friendTofriendOpenEventNotification"; //TymepassEvent
            	$_REQUEST['attending'] = "3"; 
            	$db->db_insert("invitation");
            	@sendMessageToPhone($row['deviceId'], $msg, "Event", $eventId);
            }
        }
    }
}

function sendChattingNotification(){
    $db = new db_class();
    $where = "serverId = '". $_REQUEST['fromUser'] ."'";
    $data = $db->db_select("user", "name", $where);
    $UserName = $data[0]['name'];

    $where = "serverId = '".$_REQUEST['toUser']."'";
    $data = $db->db_select("user", "deviceId", $where);
    $deviceId = $data[0]['deviceId'];
    $message = $_REQUEST['message'];
    $msg = "$UserName: ".substr(urldecode($message),0,80);
    sendMessageToPhone($deviceId, $msg, "PersonalMessage", $_REQUEST['fromUser']);
}

function sendMessageToPhone($deviceToken, $msg, $type = "", $serverId="") {

    if($deviceToken !="00000000" && $deviceToken !="")
    {

        require_once 'urbanairship.php';
        $APP_MASTER_SECRET = 'yZpRiOPdRYuwHJEwBWu8_A';
        $APP_KEY = 'WiFmZfTxSp-BImL0w7fY9w';
        $airship = new Airship($APP_KEY, $APP_MASTER_SECRET);
        $airship->register($deviceToken, 'Tymepass');
        $broadcast_message = array('aps' => array('alert' => $msg, 'messageType' => $type, "sound" => "default" , "serverId" =>$serverId));
        $airship->push($broadcast_message, array($deviceToken));
    }
}

function send_mail_password($emailaddress) {

    $db = new db_class();
    $to  = $emailaddress;//"jason@mobispector.com";//$_REQUEST['email'];
    $where = "email='". @$emailaddress ."'";
    $data = $db->db_select("user", "*" ,$where);
    $link = "http://" . $_SERVER['HTTP_HOST'] ."/password/?id=".md5($to);
    $subject = 'Tymepass Password Reset';
    $message = '
            <html>
            <head>
            <title>Tymepass</title>
            </head>
            <body>
            <p>We have recieved a request to change your Tymepass password.</p>
            <table>
                <tr>
                    <td>Email: </td><td>'. $data[0]['email']  .'</td>
                            </tr>
                            <tr>
                            <td>
                            <a href="' .$link .'" >Click here</a> to reset your Tymepass password
                                    </td>
                                    </tr>
                                    </table>

                                    Thank You<br/><br/>
                                    The Tymepass Team
                                    </body>
                                    </html>
                                    ';
    $headers  = 'MIME-Version: 1.0' . "\r\n";
    $headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";
    $headers .= 'From: TymePass <info@tymepass.com>' . "\r\n";
    @mail($to, $subject, $message, $headers);


}

function check_invitation($touser, $fromuser, $event=""){
    $where = "((`toUser`= '" . $touser . "' and `fromUser`= '" . $fromuser . "' )";
    $where .= " or (`toUser`= '" . $fromuser . "' and `fromUser`= '" . $touser . "' ))";
    if($event!="" && $event!="0")
    {
        $where .= " and `eventId`= $event";
    }
    else
    {
        $where .=" and (`type` = 'TymepassUser' OR `type` = 'FacebookUser' OR `type` = 'TwitterUser')";
    }


    $db = new db_class();
    $data = $db->db_select("invitation", "*", $where);


    if(empty($data))
    {
        return true;
    }
    else
    {
        return false;
    }
}

function recursionOnlyChield($id) {
   
    $db = new db_class();
    
    $where  =  "perent='" . $id . "'";
    $oldEntryies = $db->db_select("events" , "id" ,$where );
    $oldIds  = array();
    foreach ($oldEntryies as $row){
          $oldIds[] = $row['id'];
    }
    $result = array();
    $_REQUEST['perent'] = $id;   
    //added by jason
   // $_REQUEST['attending']=1;
    //end
    $i = 0;
    if($_REQUEST['recurring']==0)
    {
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return array();
    }    
    else if($_REQUEST['recurring']==1)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
        while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            if($i<count($oldIds))
            {
                $_REQUEST['id'] = $oldIds[$i];
                $db->db_update("events");
                $res1['id'] =  $oldIds[$i];
                $result[] = $res1;
                $i++;
            }
            else
            {
               $result[] = $db->db_insert("events"); 
            }                                       
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
     else if($_REQUEST['recurring']==2)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
        $date = strtotime($_REQUEST['startTime']);
        $date = date("l", $date);
        $date = strtolower($date);

         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {

            if($date == "saturday" || $date == "sunday")
            {
                 
            }
            else {
                if($i<count($oldIds))
                {
                    $_REQUEST['id'] = $oldIds[$i];
                    $db->db_update("events");
                    $res1['id'] =  $oldIds[$i];
                    $result[] = $res1;
                    $i++;
                }
                else
                {
                   $result[] = $db->db_insert("events"); 
                }                                       
            
            }

            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
            $date = strtotime($_REQUEST['startTime']);
            $date = date("l", $date);
            $date = strtolower($date);

        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==3)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 week'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 week'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 week'));
        while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))
        {
            if($i<count($oldIds))
            {
                $_REQUEST['id'] = $oldIds[$i];
                $db->db_update("events");
                $res1['id'] =  $oldIds[$i];
                $result[] = $res1;
                $i++;
            }
            else
            {
               $result[] = $db->db_insert("events"); 
            }                                       
            
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 week'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 week'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 week'));

        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==4)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +2 week'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +2 week'));
        $_REQUEST['servertime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['servertime'] . ' + 2 week'));
         
         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            if($i<count($oldIds))
            {
                $_REQUEST['id'] = $oldIds[$i];
                $db->db_update("events");
                $res1['id'] =  $oldIds[$i];
                $result[] = $res1;
                $i++;
            }
            else
            {
               $result[] = $db->db_insert("events"); 
            }                                       
            
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +2 week'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +2 week'));
            $_REQUEST['servertime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['servertime'] . ' + 2 week'));
             
        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==5)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 month'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 month'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 month'));
         
         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            if($i<count($oldIds))
            {
                $_REQUEST['id'] = $oldIds[$i];
                $db->db_update("events");
                $res1['id'] =  $oldIds[$i];
                $result[] = $res1;
                $i++;
            }
            else
            {
               $result[] = $db->db_insert("events"); 
            }                                       
            
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 month'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 month'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 month'));
             
        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==6)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 year'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 year'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 year'));
         
         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            if($i<count($oldIds))
            {
                $_REQUEST['id'] = $oldIds[$i];
                $db->db_update("events");
                $res1['id'] =  $oldIds[$i];
                $result[] = $res1;
                $i++;
            }
            else
            {
               $result[] = $db->db_insert("events"); 
            }                                       
            
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 year'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 year'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 year'));
             
        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }

    return $result;

}

function recursionAll($id , $parent) {
    $db = new db_class();
    $oldEntryies = $db->db_select("events", "id", "perent='$id' AND  `startTime` > '" .$_REQUEST['startTime'] . "'");
    
    // added by jason
   //  $_REQUEST['attending']=1;
   // done
    $oldIds  = array();
    foreach ($oldEntryies as $row){
          $oldIds[] = $row['id'];
    }

    $result = array();
    $_REQUEST['perent'] = $parent;   
    $i = 0;
    if($_REQUEST['recurring']==0)
    {
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return array();
    }    
    else if($_REQUEST['recurring']==1)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
        while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            if($i<count($oldIds))
            {
                $_REQUEST['id'] = $oldIds[$i];
                $db->db_update("events");
                $res1['id'] =  $oldIds[$i];
                $result[] = $res1;
                $i++;
            }
            else
            {
               $result[] = $db->db_insert("events"); 
            }                                       
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
     else if($_REQUEST['recurring']==2)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
        $date = strtotime($_REQUEST['startTime']);
        $date = date("l", $date);
        $date = strtolower($date);

         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {

            if($date == "saturday" || $date == "sunday")
            {
                 
            }
            else {
                if($i<count($oldIds))
                {
                    $_REQUEST['id'] = $oldIds[$i];
                    $db->db_update("events");
                    $res1['id'] =  $oldIds[$i];
                    $result[] = $res1;
                    $i++;
                }
                else
                {
                   $result[] = $db->db_insert("events"); 
                }                                       
            
            }

            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
            $date = strtotime($_REQUEST['startTime']);
            $date = date("l", $date);
            $date = strtolower($date);

        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==3)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 week'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 week'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 week'));
        while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))
        {
            if($i<count($oldIds))
            {
                $_REQUEST['id'] = $oldIds[$i];
                $db->db_update("events");
                $res1['id'] =  $oldIds[$i];
                $result[] = $res1;
                $i++;
            }
            else
            {
               $result[] = $db->db_insert("events"); 
            }                                       
            
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 week'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 week'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 week'));

        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==4)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +2 week'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +2 week'));
        $_REQUEST['servertime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['servertime'] . ' + 2 week'));
         
         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            if($i<count($oldIds))
            {
                $_REQUEST['id'] = $oldIds[$i];
                $db->db_update("events");
                $res1['id'] =  $oldIds[$i];
                $result[] = $res1;
                $i++;
            }
            else
            {
               $result[] = $db->db_insert("events"); 
            }                                       
            
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +2 week'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +2 week'));
            $_REQUEST['servertime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['servertime'] . ' + 2 week'));
             
        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==5)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 month'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 month'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 month'));
         
         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            if($i<count($oldIds))
            {
                $_REQUEST['id'] = $oldIds[$i];
                $db->db_update("events");
                $res1['id'] =  $oldIds[$i];
                $result[] = $res1;
                $i++;
            }
            else
            {
               $result[] = $db->db_insert("events"); 
            }                                       
            
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 month'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 month'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 month'));
             
        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==6)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 year'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 year'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 year'));
         
         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            if($i<count($oldIds))
            {
                $_REQUEST['id'] = $oldIds[$i];
                $db->db_update("events");
                $res1['id'] =  $oldIds[$i];
                $result[] = $res1;
                $i++;
            }
            else
            {
               $result[] = $db->db_insert("events"); 
            }                                       
            
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 year'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 year'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 year'));
             
        }
        for($i; $i<count($oldIds); $i++)
        {
            $DeleteQuery = "DELETE FROM events WHERE id='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
            $DeleteQuery = "DELETE FROM invitation WHERE eventId='". $oldIds[$i] ."'";
            $db->db_query($DeleteQuery);
        }
        return  $result  ;
    }
  
}



function recursion($id) {
    $db = new db_class();
    $result = array();
    $_REQUEST['perent'] = $id;
    if($_REQUEST['recurring']==0)
    {
        return array();
    }
    if($_REQUEST['recurring']==1)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            $result[] = $db->db_insert("events");
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
        }
        return  $result  ;
    }

    else if($_REQUEST['recurring']==2)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
        $date = strtotime($_REQUEST['startTime']);
        $date = date("l", $date);
        $date = strtolower($date);

         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {

            if($date == "saturday" || $date == "sunday")
            {
                 
            }
            else {
                $result[] = $db->db_insert("events");
            }

            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' + 1 day'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' + 1 day'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 day'));
            $date = strtotime($_REQUEST['startTime']);
            $date = date("l", $date);
            $date = strtolower($date);

        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==3)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 week'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 week'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 week'));
        while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))
        {
            $result[] = $db->db_insert("events");
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 week'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 week'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' + 1 week'));

        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==4)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +2 week'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +2 week'));
        $_REQUEST['servertime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['servertime'] . ' + 2 week'));
         
         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            $result[] = $db->db_insert("events");
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +2 week'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +2 week'));
            $_REQUEST['servertime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['servertime'] . ' + 2 week'));
             
        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==5)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 month'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 month'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 month'));
         
         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            $result[] = $db->db_insert("events");
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 month'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 month'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 month'));
             
        }
        return  $result  ;
    }
    else if($_REQUEST['recurring']==6)
    {
        $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 year'));
        $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 year'));
        $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 year'));
         
         while(date("Y-m-d", strtotime($_REQUEST['startTime'])) <= date("Y-m-d", strtotime($_REQUEST['recurringEndTime'])))  
        {
            $result[] = $db->db_insert("events");
            $_REQUEST['startTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['startTime'] . ' +1 year'));
            $_REQUEST['endTime'] = date('Y-m-d H:i:s', strtotime($_REQUEST['endTime'] . ' +1 year'));
            $_REQUEST['servertime'] = date('Y-m-d H:i', strtotime($_REQUEST['servertime'] . ' +1 year'));
             
        }
        return  $result  ;
    }



}

function get_time_diff1($dt)  {

    $o_date =  strtotime($dt);
    $c_date =  strtotime(date("Y-m-d"));

    $year  = date("Y") -  date("Y", strtotime($dt));
    $month  = date("m") -  date("m", strtotime($dt));
    $day  = date("d") -  date("d", strtotime($dt));
    if($year>0)
    {
        if($year==1)
        {
            return "1 Year ago";
        }
        else
        {
            return  $year . " Years ago";
        }

    }
    else if($month>0)
    {
        if($month==1)
        {
            return "1 Month ago";
        }
        else
        {
            return  $month. " Months ago";
        }

    }
    else if($day>0)
    {

        if($day==1)
        {
            return "1 Day ago";
        }
        else
        {
            return  $day . " Days ago";
        }

    }              
    return "Today";   
}


function iCal($eventId, $userId)
{
    $db = new db_class();
    $data = $db->db_select("eventicalid", "iCalId", " eventId = '$eventId' AND userToId= '$userId' limit 1");
    if(empty($data))
    {
        return "";
    }
    else
    {
        return $data[0]['iCalId'];
    }

}
function changeTotimezone($date)
{
//echo "<p>".$_REQUEST['userTimeZone']."</p>";
//echo "<p>".$_REQUEST['userTimeZone']." ".date( 'Y-m-d H:i' ,strtotime($date) +  $_REQUEST['userTimeZone'])."</p>";
  return  date( "Y-m-d H:i" ,strtotime($date) +  $_REQUEST['userTimeZone']);
//return  date( "Y-m-d H:i" ,strtotime($date));
}

function NewChangeIcall(){       
    $db = new db_class();
        $SQL = "UPDATE events set `iCalId` = '" . $_REQUEST['iCalId'] . "' where `id`='" . $_REQUEST['eventId'] . "' AND creatorId = '" . $_REQUEST['userFromId'] ."' limit 1";
        $db->db_query($SQL);
        
        $data = $db->db_select("eventicalid", "id", " eventId = '". $_REQUEST['eventId'] ."' AND userToId= '". $_REQUEST['userToId'] ."' limit 1");
        if(empty($data))
        {
            $db->db_insert("eventicalid");    
        }
        else
        {
            $SQL = "UPDATE eventicalid set `iCalId` = '" . $_REQUEST['iCalId'] . "' where eventId = '". $_REQUEST['eventId'] ."' AND userToId= '". $_REQUEST['userToId'] ."' limit 1";
            $db->db_query($SQL);
        }
        
        return  $data;
        
    
}

function NewEvents(){       $db = new db_class();
        $dat = array();
        
        if(isset($_REQUEST['iCalId']) && $_REQUEST['iCalId']!="")
        {
            $where = "`iCalId` = '". $_REQUEST['iCalId'] ."' AND `creatorId` = '". $_REQUEST['creatorId'] ."' AND `title` = '". addslashes($_REQUEST['title']) ."'";
            $dat = $db->db_select("events", "id", $where);
        }
        if(empty($dat))
        {
            $img = @$_REQUEST['photo'];
            if($img!="")
            {
                $img = str_replace('data:image/png;base64,', '', $img);
                $img = str_replace(' ', '+', $img);
                $data = base64_decode($img);
                $file = "upload/". $_REQUEST['creatorId'] ."-". uniqid() . '.png';
                $success = file_put_contents("../".$file, $data);
                
                $success = file_put_contents($file, $data);
                $_REQUEST['photo'] = $file;
            }
            if(isset($_REQUEST['reminderTime']) && $_REQUEST['reminderTime']!=0)
            {
                $_REQUEST['reminderTime'] = $_REQUEST['reminderTime'] / 60;
            }
            $_REQUEST['servertime'] = date("Y-m-d H:i", strtotime($_REQUEST['startTime'])- $_REQUEST['timezone']);
            $_REQUEST['startTime'] = date("Y-m-d H:i", strtotime($_REQUEST['startTime'])- $_REQUEST['timezone']);
            $_REQUEST['endTime'] = date("Y-m-d H:i", strtotime($_REQUEST['endTime'])- $_REQUEST['timezone']);
            $_REQUEST['recurringEndTime'] = date("Y-m-d H:i", strtotime($_REQUEST['recurringEndTime'])- $_REQUEST['timezone']);
            
            $res = $db->db_insert("events");
            $eventId =   $res['id'];
            $res['chield'] = array();

            $res['photo'] = $siteurl.$file;
            
            $_REQUEST['isGold']=0;
            if($_REQUEST['title']!="Happy Birthday!")
            {
                $res['chield'] =  recursion($eventId);
            }

            if($_REQUEST['isOpen']=='1')
            {
                $query = "INSERT INTO invitation (`fromUser`,`type`, `dateCreated` , `eventId`) VALUES ('". $_REQUEST['creatorId'] ."', 'OpenEvent', '" . date("Y-m-d H:i:s") . "', '". $eventId ."')";
                $db->db_query($query);
                send_OpenEventNotification($_REQUEST['creatorId'],$eventId, $res['chield'] );
            }
        }
        else
        {
            $res["id"] = $dat[0]['id'];
        }
        return  $res;
    }


/*
function EditEvent()
 {

        $_REQUEST['id'] = $_REQUEST['serverId'];
        $dd  = $db->db_select("events", "creatorId, isOpen" , "id='" . $_REQUEST['id'] . "'");
        $_REQUEST['creatorId'] = $dd[0]['creatorId'];
        $existingEventIsOpen = $dd[0]['isOpen'];

        $img = @$_REQUEST['photo'];
        if($img!="")
        {
            $img = str_replace('data:image/png;base64,', '', $img);
            $img = str_replace(' ', '+', $img);
            $data = base64_decode($img);
            $file = "upload/". $_REQUEST['id'] ."-". uniqid() . '.png';
            $success = file_put_contents($file, $data);
            $_REQUEST['photo'] = $file;
            $query = "INSERT INTO invitation (`fromUser`,`type`, `dateCreated` , `eventId`) VALUES ('". $_REQUEST['creatorId'] ."', 'EventPicture', '" . date("Y-m-d H:i:s") . "', '". $_REQUEST['id'] ."')";
            $db->db_query($query);

        }
        else
        {
            $no_update[] ='photo';
        }
        $no_update[] = "creatorId";
        //$no_update[] = "perent";

        if(isset($_REQUEST['reminderTime']) && $_REQUEST['reminderTime']!=0)
        {
            $_REQUEST['reminderTime'] = $_REQUEST['reminderTime'] / 60;
        }
        
            $_REQUEST['servertime'] = date("Y-m-d H:i", strtotime($_REQUEST['startTime'])- $_REQUEST['timezone']);
            $_REQUEST['startTime'] = date("Y-m-d H:i", strtotime($_REQUEST['startTime'])- $_REQUEST['timezone']);
            $_REQUEST['endTime'] = date("Y-m-d H:i", strtotime($_REQUEST['endTime'])- $_REQUEST['timezone']);
            $_REQUEST['recurringEndTime'] = date("Y-m-d H:i", strtotime($_REQUEST['recurringEndTime'])- $_REQUEST['timezone']);
            $_REQUEST['perent'] = 0;
            
            $where = "id = '" . $_REQUEST['serverId'] . "' AND
                    recurringEndTime = '" . $_REQUEST['recurringEndTime'] . "' AND
                            endTime = '" . $_REQUEST['endTime'] . "' AND
                                    startTime = '" . $_REQUEST['startTime'] . "'";
            $checkOld = $db->db_select("events", "*", $where);
            $res = $db->db_update("events", $no_update);
            
            $dd  = $db->db_select("events", "creatorId" , "id='" . $_REQUEST['id'] . "'");
            $_REQUEST['creatorId'] = $dd[0]['creatorId'];
            if($_REQUEST['isOpen']!=1)
            {
                send_EventEditNotification($_REQUEST['serverId']);    
            }
            $data = array(); 
            $query = "INSERT INTO invitation (`fromUser`,`type`, `dateCreated` , `eventId`) VALUES ('". $_REQUEST['creatorId'] ."', 'EventUpdate', '" . date("Y-m-d H:i:s") . "', '". $_REQUEST['serverId'] ."')";
            $db->db_query($query);     
        
            if($_REQUEST['parentServerId'] == 0 && $_REQUEST['saveCurrentEventOnly']==0)
            {
                $data['chield'] =  recursionOnlyChield($_REQUEST['id']);
                if($_REQUEST['isOpen']==1)
                {
               		//check if the existing event is already open, if it is then just send out that the event has been modified
                	if ($existingEventIsOpen==0){
                  		send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id'], $data['chield']);     
                	}
               		else {
                 		send_EventEditNotification($_REQUEST['serverId']);   
                	}
                }
            }
            else if($_REQUEST['saveCurrentEventOnly']==0)
            {
                
                $quety = "UPDATE events set recurringEndTime = '". $_REQUEST['startTime']  ."' where id='". $_REQUEST['parentServerId'] ."'";
                $db->db_query($quety);
                $quety = "UPDATE events set recurringEndTime = '". $_REQUEST['startTime']  ."' where perent ='". $_REQUEST['parentServerId'] ."' AND  `startTime` < '" .$_REQUEST['startTime'] . "' ";
                $db->db_query($quety);   
                $quety = "UPDATE events set `perent`='0' where id='". $_REQUEST['serverId'] ."'";
                $db->db_query($quety);
                $data['chield'] =  recursionAll($_REQUEST['parentServerId'], $_REQUEST['serverId']);
                if($_REQUEST['isOpen']==1)
                {
                    //check if the existing event is already open, if it is then just send out that the event has been modified
                	if ($existingEventIsOpen==0){
                  		send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id'], $data['chield']);     
                	}
               		else {
                 		send_EventEditNotification($_REQUEST['serverId']);   
                	}     
                }
            }
            else if($_REQUEST['saveCurrentEventOnly']==1)
            {
                $quety = "UPDATE events set `perent`='0', `recurring`='0' , recurringEndTime = '0000-00-00' where id='". $_REQUEST['serverId'] ."'";
                $db->db_query($quety);
if($_REQUEST['isOpen']==1)
                {
                    //send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id'], $data['chield']);  
 //check if the existing event is already open, if it is then just send out that the event has been modified
                	if ($existingEventIsOpen==0){
 		               	send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id']   );   
 					}
               		else {
                 		send_EventEditNotification($_REQUEST['serverId']);   
                	}
 
 
            }
/*
if($_REQUEST['isOpen']!=1)
            {
                send_EventEditNotification($_REQUEST['serverId']);    
            }*/
                    
           /* }
          $data['photo'] = $siteurl.$file;  
        $data["id"] = 201;
        return  json_encode($data);
       
    } */



?>
