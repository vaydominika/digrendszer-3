<?php

  $debugging= true;
  $debugging= false;
  error_reporting(E_ALL);
  ini_set("display_errors", "On");
  $aw= 12;
  $expand= false;
  $view_hex= false;
  
  if (isset($argv[0]))
  {
    $fin= '';
    for ($i=1; $i<$argc; $i++)
    {
      if ($argv[$i] == "-h")
      {
	$_REQUEST['submit']= "View hex";
	//echo "HEX!\n";
	$view_hex= true;
      }
      else if ($argv[$i] == "-m")
      {
	$i++;
	$aw= $argv[$i];
	$expand= true;
      }
      else
      {
	$_REQUEST['submit']= "";
	$fin= $argv[$i];
      }
    }
    if ($fin=='')
    {
      echo "asm file missing\n";
      exit(1);
    }
    //echo "FIN=$fin\n";
    $src= file_get_contents($fin);
  }
  else
  {
    if ($_REQUEST['submit'] == "Download verilog file")
    {
      header("Content-Type: application/octet-stream");
      header('Content-Disposition: attachment; filename="mem.v"');
      $debugging= false;
    }
    else
      echo "<pre>";
    $src= $_REQUEST['src'];
  }
  
  function debug($x, $color="magenta")
  {
    global $debugging;
    
    if ($debugging === true)
      echo "<font color=$color>// $x</font>\n";
  }

  $lnr= 1;
  $addr= 0;
  $mem= array();

  function mk_symbol($name, $value, $constant= false)
  {
    global $syms, $lnr;
    $sym= array(
      "name" => $name,
	"value" => $value,
	"line" => $lnr,
	"const" => $constant
    );
    $syms[$name]= $sym;
  }

  $conds= array(
    "ALL" => 0,
      "S0" => 0x10000000,
      "S1" => 0x30000000,
      "C0" => 0x50000000,
      "C1" => 0x70000000,
      "Z0" => 0x90000000,
      "Z1" => 0xb0000000,
      "O0" => 0xd0000000,
      "O1" => 0xf0000000,

      "Z"  => 0xb0000000,
      "NZ" => 0x90000000
  );

  function is_cond($W)
  {
    global $conds;
    debug(";is_cond($W);");
    if (!isset($conds[$W]))
      return false;
    $cond= $conds[$W];
    return $cond;
  }

  $insts= array(
    "NOP" => array(
        "value"=>0x00000000,
        "params"=>"rrr",
        "style"=>false),
    "LD" => array(
        "value"=>0x01000000,
        "params"=>"RR",
        "style"=>false),
    "ST" => array(
        "value"=>0x02000000,
        "params"=>"RR",
        "style"=>false),
    "MOV" => array(
        "value"=>0x03000000,
        "params"=>"RR",
        "style"=>false),
    "LDL0" => array(
        "value"=>0x04000000,
        "params"=>"RD",
        "style"=>"L"),
    "LDL" => array(
        "value"=>0x05000000,
        "params"=>"RD",
        "style"=>"L"),
    "LDH" => array(
        "value"=>0x06000000,
        "params"=>"RD",
        "style"=>"H"),
    "CALL" => array(
        "value"=>0x08000000,
        "params"=>"D",
        "style"=>"C"),

    "ADD" => array(
        "value"=>0x07000000|(0<<7),
        "params"=>"RRR",
        "style"=>false),
    "ADC" => array(
        "value"=>0x07000000|(1<<7),
        "params"=>"RRR",
        "style"=>false),
    "SUB" => array(
        "value"=>0x07000000|(2<<7),
        "params"=>"RRR",
        "style"=>false),
    "SBB" => array(
        "value"=>0x07000000|(3<<7),
        "params"=>"RRR",
        "style"=>false),
    "INC" => array(
        "value"=>0x07000000|(4<<7),
        "params"=>"Re",
        "style"=>false),
    "DEC" => array(
        "value"=>0x07000000|(5<<7),
        "params"=>"Re",
        "style"=>false),
    "AND" => array(
        "value"=>0x07000000|(6<<7),
        "params"=>"RRR",
        "style"=>false),
    "OR" => array(
        "value"=>0x07000000|(7<<7),
        "params"=>"RRR",
        "style"=>false),
    "XOR" => array(
        "value"=>0x07000000|(8<<7),
        "params"=>"RRR",
        "style"=>false),
    "SHL" => array(
        "value"=>0x07000000|(9<<7),
        "params"=>"Re",
        "style"=>false),
    "SHR" => array(
        "value"=>0x07000000|(10<<7),
        "params"=>"Re",
        "style"=>false),
    "ROL" => array(
        "value"=>0x07000000|(11<<7),
        "params"=>"Re",
        "style"=>false),
    "ROR" => array(
        "value"=>0x07000000|(12<<7),
        "params"=>"Re",
        "style"=>false),
    "MUL" => array(
        "value"=>0x07000000|(13<<7),
        "params"=>"RRR",
        "style"=>false),
    "DIV" => array(
        "value"=>0x07000000|(14<<7),
        "params"=>"RRR",
        "style"=>false),
    "CMP" => array(
        "value"=>0x07000000|(15<<7),
        "params"=>"RRR",
        "style"=>false),
    "SHA" => array(
        "value"=>0x07000000|(16<<7),
        "params"=>"Re",
        "style"=>false),
    "SETC" => array(
        "value"=>0x07000000|(17<<7),
        "params"=>false,
        "style"=>false),
    "CLRC" => array(
        "value"=>0x07000000|(18<<7),
        "params"=>false,
        "style"=>false),

    "JMP" => array(
        "value"=>0x04f00000, // LDL0 R15,D
        "params"=>"D",
        "style"=>"L"),
    "JZ" => array(
        "value"=>0xb4f00000, // Z1 LDL0 R15,D
        "params"=>"D",
        "style"=>"L"),
    "JNZ" => array(
        "value"=>0x94f00000, // Z0 LDL0 R15,D
        "params"=>"D",
        "style"=>"L"),
    "JP" => array(
        "value"=>0x03f00000, // MOV R15,R
        "params"=>"R",
        "style"=>false),
    "RET" => array(
        "value"=>0x03fe0000, // MOV R15,R14
        "params"=>false,
        "style"=>false),
    "PUSH" => array(
        "value"=>0x020d0000, // ST R,R13
        "params"=>"R",
        "style"=>false),
    "POP" => array(
        "value"=>0x010d0000, // LD R,R13
        "params"=>"R",
        "style"=>false)
  );

  function is_inst($W)
  {
    global $insts;
    debug(";is_inst($W);");
    if (!isset($insts[$W]))
    {
      //debug(";is_inst($W); not inst");
      return false;
    }
    $inst= $insts[$W];
    return $inst;
  }

  function w2r($w)
  {
    $W= strtoupper($w);
    if ($W == "PC")
      $r= 15;
    else if ($W == "LR")
    $r= 14;
    else if ($W == "SP")
    $r= 13;
    else
    {
      if ($W[0] == 'R')
      {
	$w= substr($w, 1);
        $W= substr($W, 1);
      }
      $r= intval($w,0);
    }
    return $r;
  }

  function procl($l)
  {
    global $mem, $syms, $lnr, $addr;
    $org= $l;
    $icode= 0;
    $sym= false;
    if (($w= strtok($l, " \t")) === false)
    {
      debug(";procl; no words found in line $lnr");
      return;
    }
    $prew= "";
    $par_sep= " \t,[]():;";
    $inst= false;
    $error= false;
    $ok= false;
    while ($w !== false)
    {
      debug(";procl; w=$w");
      if ($w[strlen($w)-1] == ":")
      {
        $w= substr($w, 0, strlen($w)-1);
        debug(";procl; found label=$w at addr=$addr");
        mk_symbol($w, $addr);
        $ok= true;
      }
      else
      {
        $W= strtoupper($w);
        debug(";procl; W=$W");
        $cond= is_cond($W);
        if ($cond !== false)
        {
          debug(";procl; COND= ".sprintf("%08x",$cond));
          $icode= $icode | $cond;
          debug(";procl; ICODE= ".sprintf("%08x",$icode));
        }
        else
        {
          $inst= is_inst($W);
          if ($inst !== false)
          {
            debug(";procl; INST= ".sprintf("%08x",$inst["value"])." params=${inst['params']}");
            $icode= $icode | $inst["value"];
            debug(";procl; ICODE= ".sprintf("%08x",$icode));
            $is_inst= true;
            $w= strtok($par_sep);
            $pi= 0;
            $pars= array();
            while ($w !== false)
            {
              debug(";procl; buffer param=$w");
              $pars[$pi]= $w;
              $pi++;
              $w= strtok($par_sep);
            }
            $p= $inst["params"];
            for ($pi= 0; $pi < strlen($p); $pi++)
            {
              if (($p[$pi] == strtoupper($p[$pi])) &&
                !isset($pars[$pi]))
              {
                $error= "Required parameter (${p[$pi]}) missing at pos $pi";
                debug(";ERROR; $error", "red");
                break;
              }
              if (($p[$pi] == 'e') &&
                !isset($pars[$pi]))
              {
                $rd= ($icode & 0x00f00000)>>20;
                $icode= $icode | ($rd << 16);
                debug(";procl; Ra:=Rd ($rd) ICODE=".sprintf("%08x",$icode));
                continue;
              }
              if (($p[$pi] != strtoupper($p[$pi])) &&
                !isset($pars[$pi]))
              {
                debug(";procl; non-needed ${p[$pi]} skipped");
                continue;
              }
              $P= strtoupper($p[$pi]);
              $w= $pars[$pi];
              $W= strtoupper($w);
              debug(";procl; param=$w as $P");
              if ($P == "R" || $P == "E")
              {
                $r= 0;
                if ($W == "PC")
                  $r= 15;
                else if ($W == "LR")
                $r= 14;
                else if ($W == "SP")
                $r= 13;
                else
                {
                  if ($W[0] == 'R')
                  {
                    $w= substr($w, 1);
                    $W= substr($W, 1);
                  }
                  $r= intval($w,0);
                }
                if ($pi == 0)
                {
                  $icode= $icode | ($r << 20);
                }
                if ($pi == 1)
                {
                  $icode= $icode | ($r << 16);
                }
                if ($pi == 2)
                {
                  $icode= $icode | ($r << 12);
                }
                debug(";procl; R-$pi ICODE=".sprintf("%08x",$icode));
              }
              else if ($P == "D")
              {
                $sym= $w;
                debug(";procl; D-$w as ".$inst["style"]);
              }
            }
            $ok= true;
          }
	  else if ($W == "LDI")
	  {
	    $o= sprintf(";procl; MACRO DLI in line $lnr, icode=%08h,cond=%08h",$icode,$cond);
	    debug($o);
	    $w_Rd= strtok($par_sep);
	    $r= w2r($w_Rd);
	    $sym= strtok($par_sep);
	    $cond= $icode;
	    // LDH
	    $icode= 0x06000000 | ($r<<20);
	    if ($cond!==false) $icode= $icode | $cond;
	    $st= 'H';
	    $mem[$addr]= array(
	      "code"=>$icode,
		"sym"=>$sym,
		"style"=>$st,
		"src"=>$org,
		"error"=>''
	    );
            $o= sprintf("%04x %08x %s:%s", $addr, $icode, $sym, $st);
	    debug($o, "blue");
            $addr++;
	    // LDL
	    $icode= 0x05000000 | ($r<<20);
	    if ($cond!==false) $icode= $icode | $cond;
	    $st= 'L';
	    $mem[$addr]= array(
	      "code"=>$icode,
		"sym"=>$sym,
		"style"=>$st,
		"src"=>$org,
		"error"=>''
	    );
            $o= sprintf("%04x %08x %s:%s", $addr, $icode, $sym, $st);
	    debug($o, "blue");
            $addr++;
	    // ready
	    $inst= false;
	    $ok= true;
	  }
          else if ($W == "ORG")
          {
            $w= strtok(" \t");
            $addr= intval($w,0);
            debug(";procl; addr=$addr");
            $ok= true;
          }
          else if ($W == "DB")
          {
            $icode= 0;
            $inst= array(
              "value"=> 0,
                "params"=> false,
                "style"=> 'B'
            );
            $sym= strtok(" \t");
            $ok= true;
          }
          else if ($W == "DW")
          {
            $icode= 0;
            $inst= array(
              "value"=> 0,
                "params"=> false,
                "style"=> 'W'
            );
            $sym= strtok(" \t");
            $ok= true;
          }
          else if ($W == "DD")
          {
            $icode= 0;
            $inst= array(
              "value"=> 0,
                "params"=> false,
                "style"=> 'D'
            );
            $sym= strtok(" \t");
            $ok= true;
          }
          else if ($W == "DS")
          {
            $x= 0 + strtok(" \t");
            $addr+= $x;
            debug(";procl; addr=$addr");
            $ok= true;
          }
          else if (($W == "=") || ($W == "EQU"))
          {
            $w= strtok(" \t");
            $val= intval($w,0);
            debug("EQU w=$w val=$val");
            mk_symbol($prew, $val, $W=="=");
            debug(";procl; SYMBOL $prew=$val");
            $ok= true;
          }
        }
      }
      if ($inst !== false)
      {
        debug(";procl; instruction in line $lnr");
        $mem[$addr]= array(
          "code"=>$icode,
            "sym"=>$sym,
            "style"=>$inst["style"],
            "src"=>$org,
            "error"=>$error
        );
        $o= sprintf("%04x %08x %s:%s", $addr, $icode, $sym, $inst["style"]);
        debug($o, "blue");
        $addr++;
      }
      else 
        $prew= $w;
      $w= strtok($par_sep);
    }
    if (!$ok)
    {
      //echo "ERROR\n";
      $error= "Unknown instruction";
      debug(";ERROR; $error", "red");
      $mem[$addr]= array(
        "code"=>false,
          "sym"=>false,
          "style"=>false,
          "src"=>$org,
          "error"=>$error);
      $addr++;
    }
  }
  
  $lsep= "\r\n";
  $l= strtok($src, $lsep);
  while ($l !== false)
  {
    $lines[$lnr]= $l;
    $l= strtok($lsep);
    $lnr++;
  }
  $nuof_lines= $lnr;
  debug("; $nuof_lines lines buffered");
  $addr= 0;
  $mem[$addr]= 0;
  $addr= 1;
  for ($lnr= 1; $lnr < $nuof_lines; $lnr++)
  {
    $l= trim($lines[$lnr]);
    $l= preg_replace("/;.*$/", "", $l);
    debug("\n");
    debug("; line=$lnr $l", "red");
    procl($l);
  }
  
  debug("\n\n");
  
  $hex= '';
  
  debug("SYMBOLS", "black");
  //debug ("syms[0]= ${syms[0]}");
  $hex.= "//; SYMBOLS\n";
  if (!empty($syms))
  {
    foreach ($syms as $k => $s)
    {
      if ($s['const'] == true)
	$c= '=';
      else
	$c= ';';
      $o= sprintf("//%s %08x", $c, $s["value"])." $k";
      $hex.= $o."\n";
      debug($o, 'black');
    }
  }
  
  debug(";  PHASE 2\n");
  
  foreach ($mem as $a => $m)
  {
    //echo "a=$a, m=".print_r($m,true)."\n";
    if (!is_array($m))
      continue;
    debug(";ph2; addr=$a code=".sprintf("%08x",$m['code'])." sym=${m['sym']} style=${m['style']}");
    if ($m["sym"] !== false)
    {
      $sval= 0;
      $sname= $m['sym'];
      if (strspn($m['sym'], '0123456789+-') > 0)
      {
        $sval= intval($m['sym'],0);
        debug(";ph2; sym(${m['sym']}) is number= $sval");
      }
      else if ($sname[0] == "'")
      {
	$c= substr($sname,1,1);
	$sval= ord($c);
	debug(";ph2; sym({$m['sym']}) is char= $sval");
      }
      else if (substr($sname,0,2)=="' ")
      {
	$sval= 32;
	debug(";ph2; sym({$m['sym']}) is char= $sval");
      }
      else
      {
        if (!isset($syms[$m["sym"]]))
        {
          debug(";ERROR ${m['sym']} undefined");
        }
        else
        {
          $sval= $syms[$m['sym']]['value'];
          debug(";ph2; symbol= $sval");
        }
      }
      
      if ($m['style'] == 'L')
        $m["code"]= ($m['code'] & 0xffff0000) | ($sval & 0x0000ffff);
      else if ($m['style'] == 'H')
      $m["code"]= ($m['code'] & 0xffff0000) | (($sval & 0xffff0000) >> 16);
      else if ($m['style'] == 'C')
      $m["code"]= ($m['code'] & 0xf8000000) | ($sval & 0x07fffffff);
      else if ($m['style'] == 'B')
      $m["code"]= $sval & 0x000000ff;
      else if ($m['style'] == 'W')
      $m["code"]= $sval & 0x0000ffff;
      else if ($m['style'] == 'D')
      $m["code"]= $sval & 0xffffffff;
      else
        debug(";ERROR unknown style ${m['style']}");
      debug(";ph2; ".sprintf("%08x",$m['code']));
      $mem[$a]= $m;
    }
  }
  debug("; PHASE 2 done");
  
  $hex.= "//; CODE\n";
  $p= -1;
  foreach ($mem as $a => $m)
  {
    if (!is_array($m))
      continue;
    debug(";ph3; addr=$a code=".sprintf("%08x",$m['code'])." sym=${m['sym']} style=${m['style']}");
    if ($a != $p+1)
    {
      $p++;
      while ($p < $a)
      {
        $o= sprintf("%08x ;%04x", 0, $p);
        debug($o, "darkgreen");
        $hex.= $o."\n";
        $p++;
      }
    }
    $p= $a;
    if ($m['code'] !== false)
    {
      $o= sprintf("%08x //;%04x %s", $m['code'], $a, $m["src"]);
      debug($o, "darkgreen");
      $hex.= $o."\n";
      if ($m["error"] != false)
      {
        $o= "; ERROR: ".$m['error'];
        debug($o, "red");
        $hex.= $o."\n";
      }
    }
    else if ($m['error'] !== false)
    {
      $o= sprintf("; ERROR: %s in \"%s\"", $m['error'], $m['src']);
      debug($o, "red");
      $hex.= "; ".$o."\n";
    }
    else
      debug(";ph3; what?");
  }
  $a++;
  $mem_size= 1<<$aw;
  if ($expand)
    for ( ; $a < $mem_size; $a++)
      $hex.= sprintf("%08x //;%04x\n", 0, $a);
  
  $_REQUEST['hex']= $hex;
  //echo "REQ={$_REQUEST['submit']} vh=$view_hex aw=$aw\n";
  if (/*isset($argv[0]) ||*/
    //($_REQUEST['submit']!='View hex')
    !$view_hex
  )
  include('gen.php');
  else
  {
    //echo "HEHEX {$_REQUEST['submit']}\n";
    echo $hex;
  }
?>
