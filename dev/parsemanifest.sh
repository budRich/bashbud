#!/bin/env bash

___parsemanifest(){
  local f="$1"
  awk '
  BEGIN {sqo="'"'"'";sqol=sqo "\"" sqo "\"" sqo;chain=0}
  {
    # esacpe single quotes
    gsub(sqo,sqol)

    if (match($0,/[[:space:]]*[#] (additional|long|option|env)-(.*)[[:space:]]*$/,ma)) {

      if (curvar && avar[curvar]=="X") {
        avar[curvar]="INCHAIN"
        if (chain == 0) {chain=curvar}
        else {chain=curvar " " chain }
      }

      curvar=ma[1]"-"ma[2]
      avar[curvar]="X"
      start=1
    }

    else if (start==1 && $0 !~ /^[[:space:]]*$/) {start++;blanks=0}
    if (start==2) {
      if (chain != 0) {
        avar[curvar]="CHAIN=" chain "\n" $0
        chain=0
      } 
      else
        avar[curvar]=$0
      start++
    }
    
    else if (start>2 && $0 ~ /^[[:space:]]*$/) {blanks++}
    else if (start>2) {
      nl="\n"
      for (i=0;i<blanks;i++){
        nl=nl "\n"
      }
      avar[curvar]=avar[curvar] nl $0
      blanks=0
    }
  }
  END {
    for (k in avar) {
      printf "___info[%s]="sqo"%s"sqo"\n", k, avar[k]
    }

  }
  ' "$f"
}
