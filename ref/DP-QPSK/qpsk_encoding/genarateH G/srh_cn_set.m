 
 function [cn_set] = srh_cn_set(cn,H,girth)
 
 % Get the check nodes set.
 % [cn_set] = srh_cn_set(cn,H,girth)
 % cn_set denotes the set of all check nodes that can create any cycle of
 % length (girth-2) or smaller betweent th given check node "cn" in spare
 % parity check matrix H.
 % girth is required to be even.
 %
 % See also bit_filling.

 %   Copyright (C) 2007, Guangrong Fan. MCL. BIT.
 %   $Revision: 1.0 $  $Date: 2007/07/26 20:45:02 $
 

 cn_set = cn; 
 cn_temp = [];
 
 for i = 1:1:(girth/2-2);
   cn_length = length(cn_set);
   for j = 1:1:cn_length 
     vn_temp = find( H(cn_set(j),:) == 1);
     if ( ~isempty(vn_temp) )         
       for vn_temp_num = 1:length(vn_temp);
         cn_temp = [cn_temp,find( H(:,vn_temp(vn_temp_num)) == 1).'];     
       end;     
       cn_temp = unique(cn_temp); % set unique
     end;
   end;
   cn_set = cn_temp;
 end;
 