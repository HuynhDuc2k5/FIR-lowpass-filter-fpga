%FIR Filter Hamming Window 
%Order = 8 
%FCut = 3K 
%Coffiecients File 


BitResolution = 16 ; 

scale_factor = (2^(BitResolution - 1)) - 1; 
Cof_16bit = int16(round(Num * scale_factor));

FIRCof = fopen('FIRCof.hex','w'); 

    for i = 1:length(Cof_16bit)
        
        HexData = typecast (Cof_16bit(i), 'uint16');
        fprintf(FIRCof,'%04X\n',HexData)
    
    end

fclose(FIRCof); 