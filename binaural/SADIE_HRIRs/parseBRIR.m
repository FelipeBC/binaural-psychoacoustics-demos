fileList = dir('*.wav');
fileList = {fileList.name}';
az_angles = zeros(50,1);
el_angles = zeros(50,1);
HRIR_set_L = zeros(13230,50);
HRIR_set_R = zeros(13230,50);
for i = 1:50
    splitString1 = strsplit(string(fileList(i)),'_');
    splitString2 = strsplit(splitString1(4),'.');
    az_str = splitString1(2);
    el_str = splitString2(1);
    az_str = strrep(az_str,',','.');
    el_str = strrep(el_str,',','.');
    az_angles(i) = str2double(az_str);
    el_angles(i) = str2double(el_str);
    [HRIR,fs] = audioread(string(fileList(i)));
    HRIR_set_L(:,i) = HRIR(:,1);
    HRIR_set_R(:,i) = HRIR(:,2);
end

HRIR_set_L = HRIR_set_L';
HRIR_set_R = HRIR_set_R';
az_angles = rem(360-az_angles,360);
az_el_angles = [az_angles,el_angles];


save('BRIR_parse.mat','HRIR_set_L','HRIR_set_R','fs','az_el_angles')