//This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
//Please refer to the LICENSE and README files for information on licensing and authorship of this file.
//Copyright (C) 2015 Genome Research Ltd.
//This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
//Please refer to the LICENSE and README files for information on licensing and authorship of this file.
//Copyright (C) 2007-2011 Genome Research Ltd.
function createNameAsset()
{
 var from = document.getElementById('study_id_from').value
 var to = document.getElementById('study_id_to').value
 var string = ""

 string = "moved_" + from + "_"+ to + "_";
 document.getElementById('new_assets_name').value = string;
}

function searchSel() {
  var input=document.getElementById('search_study').value.toLowerCase();
  var output=document.getElementById('study_id_to').options;
  var trovato = 0;

  if (input !="")
  {
    select_size = output.length;
    study_number = parseInt(input);

    for(var i=0;i< select_size-1;i++) {
      study_opt = output.item(i).value;
      study_opt_val = parseInt(study_opt);
      if(study_number == study_opt_val)
      {
         output[i].selected=true;
         trovato = 1;
      }
    }
    if (trovato == 0) { alert("Study not found."); }
  }
  else
  {
    output[0].selected=true;
  }
}

