<?php
    include("dbclass.php");
$db = new db_class();

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
   $_REQUEST['userTimeZone'] = @$time;
   $_REQUEST['CURRENTUSERID'] = @$zone;
@header('Content-Type: application/json; charset= ');
echo "[";

include("functions.php");
switch ($action) {
    case "newEvent": {
        
        
        
    }
}

function NewEvent()
{
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
                $file = "upload/". uniqid() . '.png';
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
        return  json_encode($res);
    }

function EditEvent()
 {

        $_REQUEST['id'] = $_REQUEST['serverId'];
        $dd  = $db->db_select("events", "creatorId" , "id='" . $_REQUEST['id'] . "'");
        $_REQUEST['creatorId'] = $dd[0]['creatorId'];

        $img = @$_REQUEST['photo'];
        if($img!="")
        {
            $img = str_replace('data:image/png;base64,', '', $img);
            $img = str_replace(' ', '+', $img);
            $data = base64_decode($img);
            $file = "upload/". uniqid() . '.png';
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
                    send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id'], $data['chield']);     
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
                    send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id'], $data['chield']);     
                }
            }
            else if($_REQUEST['saveCurrentEventOnly']==1)
            {
                $quety = "UPDATE events set `perent`='0', `recurring`='0' , recurringEndTime = '0000-00-00' where id='". $_REQUEST['serverId'] ."'";
                $db->db_query($quety);
                send_OpenEventNotification($_REQUEST['creatorId'],$_REQUEST['id']   );     
            }
            
        $data["id"] = 201;
        return  json_encode($data)
        exit;
        break;
    }

?>