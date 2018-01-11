
clear all;
clc;
close all;
tic;
%%for extraction of image containing text
I=imread('ICDAR18.jpg');
texture_image=imread('ICDAR18_texture.jpg');
[wall_texture]=tester25(texture_image);
[ti,wti]=test_word_segmentation(I);
text_image=ti;
%text_image=test_word_segmentation(I);
[room_locations,cc1,rect_cell1]= room_segmentation1(I);
room_locations_temp=room_locations;
[sizeX,sizeY]=size(I);
%% evaluation of decors names and locations
testim=wti;
[decor_locn,decorName,decor_index,st1]=classify_objects(testim);
%% evaluation of the matrix containing coordinates of bounding boxes of
% words
location_matrix=Segmentation(text_image);
[m,n]=size(location_matrix);
cent1=zeros(m,2);
matfiles = dir(fullfile('D:','Data','PhD','textual description','wall segmentation','output','*.png'));
%% calculation of centroid of each bouding box
for(i=1:m)
    cent1(i,1)= location_matrix(i,1)+(round((location_matrix(i,3)-location_matrix(i,1))/2));
end
for(i=1:m)
    cent1(i,2)=location_matrix(i,2)+round((location_matrix(i,4)-location_matrix(i,2))/2);
end
s=CStack();
stX=CStack();
stY=CStack();
%% calculation of distance matrix of each centroid to the next centroid
dist1=zeros(m,1);
for i=1:m-1
    dist1(i+1,1)=sqrt(((cent1(i+1,1)-cent1(i,1))*(cent1(i+1,1)-cent1(i,1)))+((cent1(i+1,2)-cent1(i,2))*(cent1(i+1,2)-cent1(i,2))));
end
%dist1=pdist(cent1);
%% estimation of  bounding boxes of all the words

s.push(1);
stX.push(cent1(1,1));
stY.push(cent1(1,2));
field1='wordCentX';
field2='wordCentY';
field3='roomName';
field4='room_CoordinateX';
field5='room_CoordinateY';
field6='roomArea';
field7='roomLabel'
%field8='roomSize'
value1={};
value2={};
value3={};
value4={};
value5={};
value6={};
value7={};
%value8={};
RoomInfoStruct = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5,field6,value6,field7,value7);
j=0; % word count
for i=2:m
    if dist1(i)>50
        wordStr = '';
        counter3=1;
        while ~isempty(s)
            %disp('pop');
            tempStr = s.pop();
            vecX(counter3)=stX.pop(); % x coords stack
            avg1(i-1,1)=sum(vecX)/counter3;
            vecY(counter3)=stY.pop();
            avg1(i-1,2)=sum(vecY)/counter3;
            counter3=counter3+1;
            % Recognize the text in the image tempStr.png
            d=num2str(tempStr);
            i1=imread((strcat('D:\Data\PhD\textual description\wall segmentation\output\',d,('.png'))));
            %i1=imread((strcat('D:\Data\PhD\textual description\wall segmentation\output\',(matfiles(tempStr).name))));
            str1=one_padding(i1);
            % wordStr = strcat(num2str(tempStr),wordStr);
            wordStr = strcat(str1,wordStr);
            % disp(wordStr);
        end
        clear('vecX','vecY');
        % Check whether the word is valid or not
        if(length(wordStr)>3)
             j = j+1 ;
             avg_final(j,1)=avg1(i-1,1);
             avg_final(j,2)=avg1(i-1,2);
%             cent(j,1) = sum(vecX)/counter3;
%             cent(j,2) = sum(vecY)/counter3;
            celldata(i)=cellstr(wordStr);
            %clear('vecX','vecY');
            RoomInfoStruct(j).wordCentX=avg1(i-1,1);
            RoomInfoStruct(j).wordCentY=avg1(i-1,2);
            RoomInfoStruct(j).roomName=cellstr(wordStr);
        end
        % Assign this word to a room
    end
    i;
    s.push(i); % Stack of Alphabets
    stX.push(cent1(i,1)); % Stack of X coordinates
    stY.push(cent1(i,2)); % Stack of Y coordinates
end
wordStr1='';
[k,l]=size(celldata);
[k1,l1]=size(avg1);
[k2,l2]=size(avg_final);
%[k1,l1]=size(cent);
counter4=1;
% Checking the leftover alphabets in the stack
for i=1:s.size()
    % wordStr1='';
    tempStr1=s.top();
    s.pop();
    vecX(counter4)=stX.pop();
    avg1(k1+1,1)=sum(vecX)/counter4;
    vecY(counter4)=stY.pop();
    avg1(k1+1,2)=sum(vecY)/counter4;
    counter4=counter4+1;
    d1=num2str(tempStr1);
    i2=imread((strcat('D:\Data\PhD\textual description\wall segmentation\output\',d1,('.png'))));
    str2=one_padding(i2);
    wordStr1 = strcat(str2,wordStr1);
    %disp(wordStr1);
end
% Check for Valid Word
if(length(wordStr1)>3)
    avg_final(k2+1,1)=avg1(k1+1,1);
    avg_final(k2+1,2)=avg1(k1+1,2);
%     cent(k1+1,1) = sum(vecX)/counter4;
%     cent(k1+1,2) = sum(vecY)/counter4;
    celldata(l+i)=cellstr(wordStr1);
    RoomInfoStruct(k2+1).wordCentX=avg1(k1+1,1);
            RoomInfoStruct(k2+1).wordCentY=avg1(k1+1,2);
            RoomInfoStruct(k2+1).roomName=cellstr(wordStr1);
end
%% matching extracted words for the correct words
celldata=celldata.';
[k,l]=size(celldata);
s2='BEDROOM';
s3='KITCHEN';
s4='BATHROOM';
s5='ENTRY';
s6='LIVINGROOM';
s7='HALL';
s9='CHAMBRE1';
s10='CHAMBRE2';
s11='CHAMBRE3';
s12='BAINS';
s13='SEJOUR';
s14='CELLIER';
s15='CUISINE';
s16='GARAGE';
%i=1;
for i=1:k
    s1=cell2mat(celldata(i));
    
    if(EditDistance(s1,s2)==0 || EditDistance(s1,s2)==1 || EditDistance(s1,s2)==2)%|| EditDistance(s1,s2)==3 )
        celldata(i)=cellstr(s2);
    elseif (EditDistance(s1,s3)==0 || EditDistance(s1,s3)==1 || EditDistance(s1,s3)==2)% || EditDistance(s1,s3)==2)
        celldata(i)=cellstr(s3);
    elseif(EditDistance(s1,s4)==0 || EditDistance(s1,s4)==1 || EditDistance(s1,s4)==2)%|| EditDistance(s1,s4)==2)      %string matching
        celldata(i)=cellstr(s4);
    elseif(EditDistance(s1,s5)==0 || EditDistance(s1,s5)==1 || EditDistance(s1,s5)==2 )% || EditDistance(s1,s5)==2)
        celldata(i)=cellstr(s5);
    elseif(EditDistance(s1,s6)==0 || EditDistance(s1,s6)==1 || EditDistance(s1,s6)==2) %|| EditDistance(s1,s6)==2)
        celldata(i)=cellstr(s6);
    elseif(EditDistance(s1,s7)==0 || EditDistance(s1,s7)==1 || EditDistance(s1,s7)==2)% || EditDistance(s1,s7)==2)
        celldata(i)=cellstr(s7);
    elseif(EditDistance(s1,s9)==0 || EditDistance(s1,s9)==1 || EditDistance(s1,s9)==2)% || EditDistance(s1,s7)==2)
        celldata(i)=cellstr(s9);
    elseif(EditDistance(s1,s10)==0 || EditDistance(s1,s10)==1 || EditDistance(s1,s10)==2)% || EditDistance(s1,s7)==2)
        celldata(i)=cellstr(s10);
    elseif(EditDistance(s1,s11)==0 || EditDistance(s1,s11)==1 || EditDistance(s1,s11)==2)% || EditDistance(s1,s7)==2)
        celldata(i)=cellstr(s11);
    elseif(EditDistance(s1,s12)==0 || EditDistance(s1,s12)==1 || EditDistance(s1,s12)==2)% || EditDistance(s1,s7)==2)
        celldata(i)=cellstr(s12);
    elseif(EditDistance(s1,s13)==0 || EditDistance(s1,s13)==1 || EditDistance(s1,s13)==2)% || EditDistance(s1,s7)==2)
        celldata(i)=cellstr(s13);
    elseif(EditDistance(s1,14)==0 || EditDistance(s1,s14)==1 || EditDistance(s1,s14)==2)% || EditDistance(s1,s7)==2)
        celldata(i)=cellstr(s14);
    elseif(EditDistance(s1,s15)==0 || EditDistance(s1,s15)==1 || EditDistance(s1,s15)==2)% || EditDistance(s1,s7)==2)
        celldata(i)=cellstr(s15);
    elseif(EditDistance(s1,s16)==0 || EditDistance(s1,s16)==1 || EditDistance(s1,s16)==2)% || EditDistance(s1,s7)==2)
        celldata(i)=cellstr(s16);
        
    else
        
        celldata(i)=cellstr('null');
    end
    %     if(EditDistance(s1,s3)>3)
    %         celldata(i)=cellstr('null');
    %     else
    %         celldata(i)=cellstr(s3);
    %     end
    %     if(EditDistance(s1,s4)>3)
    %         celldata(i)=cellstr('null');
    %     else
    %         celldata(i)=cellstr(s4);
    %     end
    %     if(EditDistance(s1,s5)>3)
    %         celldata(i)=cellstr('null');
    %     else
    %         celldata(i)=cellstr(s5);
    %     end
    %     if(EditDistance(s1,s6)>3)
    %         celldata(i)=cellstr('null');
    %     else
    %         celldata(i)=cellstr(s6);
    %     end
    %     if(EditDistance(s1,s7)>3)
    %         celldata(i)=cellstr('null');
    %     else
    %         celldata(i)=cellstr(s7);
    %     end
    
    
end
[roomS1,roomS2]=size(RoomInfoStruct);
for(i=1:roomS2)
    strRoomStrct=cell2mat(RoomInfoStruct(i).roomName);
    if(EditDistance(strRoomStrct,s2)==0 || EditDistance(strRoomStrct,s2)==1 || EditDistance(strRoomStrct,s2)==2)
        RoomInfoStruct(i).roomName=cellstr(s2);
    elseif (EditDistance(strRoomStrct,s3)==0 || EditDistance(strRoomStrct,s3)==1 || EditDistance(strRoomStrct,s3)==2)
        RoomInfoStruct(i).roomName=cellstr(s3);
    elseif(EditDistance(strRoomStrct,s4)==0 || EditDistance(strRoomStrct,s4)==1 || EditDistance(strRoomStrct,s4)==2)      %string matching
        RoomInfoStruct(i).roomName=cellstr(s4);
    elseif(EditDistance(strRoomStrct,s5)==0 || EditDistance(strRoomStrct,s5)==1 || EditDistance(strRoomStrct,s5)==2 )
        RoomInfoStruct(i).roomName=cellstr(s5);
    elseif(EditDistance(strRoomStrct,s6)==0 || EditDistance(strRoomStrct,s6)==1 || EditDistance(strRoomStrct,s6)==2) 
        RoomInfoStruct(i).roomName=cellstr(s6);
    elseif(EditDistance(strRoomStrct,s7)==0 || EditDistance(strRoomStrct,s7)==1 || EditDistance(strRoomStrct,s7)==2)
       RoomInfoStruct(i).roomName=cellstr(s7);
       elseif(EditDistance(strRoomStrct,s9)==0 || EditDistance(strRoomStrct,s9)==1 || EditDistance(strRoomStrct,s9)==2)
       RoomInfoStruct(i).roomName=cellstr(s9);
       elseif(EditDistance(strRoomStrct,s10)==0 || EditDistance(strRoomStrct,s10)==1 || EditDistance(strRoomStrct,s10)==2)
       RoomInfoStruct(i).roomName=cellstr(s10);
       elseif(EditDistance(strRoomStrct,s11)==0 || EditDistance(strRoomStrct,s11)==1 || EditDistance(strRoomStrct,s11)==2)
       RoomInfoStruct(i).roomName=cellstr(s11);
       elseif(EditDistance(strRoomStrct,s12)==0 || EditDistance(strRoomStrct,s12)==1 || EditDistance(strRoomStrct,s12)==2)
       RoomInfoStruct(i).roomName=cellstr(s12);
       
     elseif(EditDistance(strRoomStrct,s13)==0 || EditDistance(strRoomStrct,s13)==1 || EditDistance(strRoomStrct,s13)==2)
       RoomInfoStruct(i).roomName=cellstr(s13);
       elseif(EditDistance(strRoomStrct,s14)==0 || EditDistance(strRoomStrct,s14)==1 || EditDistance(strRoomStrct,s14)==2)
       RoomInfoStruct(i).roomName=cellstr(s14);
       elseif(EditDistance(strRoomStrct,s15)==0 || EditDistance(strRoomStrct,s15)==1 || EditDistance(strRoomStrct,s15)==2)
       RoomInfoStruct(i).roomName=cellstr(s15);
       elseif(EditDistance(strRoomStrct,s16)==0 || EditDistance(strRoomStrct,s16)==1 || EditDistance(strRoomStrct,s16)==2)
       RoomInfoStruct(i).roomName=cellstr(s16);
    else
        
        RoomInfoStruct(i).roomName=cellstr('null');
    end
end
%f=CStack();
s8='null';
%i=19;
counter=0;
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));   % removing all the null values from cell array
count=cellfun(cellfind(s8),celldata());
[x,y]=size(count);
for(i=1:x)
    if(count(i)==0)
        counter=counter+1;
    end
end
finalwords=num2cell(zeros(counter,1));
%c='';
counter2=1;
for(i=1:k)
    % cell2mat(celldata(i))
    logical_cells = cellfun(cellfind(s8),celldata(i));
    if( logical_cells==0)
        % c=mat2str(cell2mat(celldata(i)));
        %for(j=1:counter)
        finalwords(counter2)=celldata(i);       % storing final words in a cell array
        % finalwords(counter2)=cellstr(c);
        counter2=counter2+1;
        %end
        %celldata(i)=[];
        %f.push(c);
    end
end
%% calculating location of rooms 
%bboxes=zeros(6,4);

% ocr1=ocr(text_image);
% ocr1.Text
% % for i=1:counter
% %     bboxes{i} = locateText(ocr1,finalwords{i});  % locating each word in the image
% % end
% 
% for i=1:counter
%     matArray{i} = locateText(ocr1,finalwords{i});
% end
% [cs1,cs2]=size(cent);
% %for(i=1:m)
% RGB = insertShape(text_image,'circle',[cent1(3,2) cent1(3,1) 10],'LineWidth',5);
% %end
% %hold on
% imshow(RGB);

[roomX, roomY]=size(room_locations);
room_locations = room_locations(100:roomX-100,100:roomY-100);
[roomX, roomY]=size(room_locations);
counter5=1;
counter6=1;

for(i=1:roomX)
    
    for(j=1:roomY)
        if(room_locations(i,j)~=0)
            %            room_name(counter5)=room_location(i,j);
            %            %if(room_name(counter5)==room_location(i,j)
            if((room_locations(i-1,j)==0 || room_locations(i+1,j)==0) &&(room_locations(i,j-1)==0 || room_locations(i,j+1)==0) )
                
                    %                    corner_room(counter6,1)=i;
                    %                    corner_room(counter6,2)=j;
                    %                    counter6=counter6+1;
                    %                end
                    %            end
                
                    
                
            else 
                room_locations(i,j)=10;
                %            % room_locations(i,j)=1;
            end
        end
    end

end
RGB_label = label2rgb(room_locations);
 figure; imshow(RGB_label,'InitialMagnification','fit');
% RGB_label=rgb2gray(RGB_label);
% [sizeX,sizeY]=size(RGB_label);
no_of_labels=cc1.NumObjects;
roomCords=num2cell(zeros(no_of_labels,1));
for(i=1:no_of_labels)
    [rowX,colY]=find(room_locations==i+1);
    cx = mean(rowX);
    cy = mean(colY);
    angleXY = atan2(colY - cy, rowX - cx);
    [~, order] = sort(angleXY);
    rowX= rowX(order);
    colY=colY(order);
    roomCords{i,1}=rowX;
    roomCords{i,2}=colY;
    patch(colY,rowX,'red')
end
%% In and out test of the words with the respective rooms
field1='room_name';
field2='room_coordinatesX1';
field3='room_coordinatesY1';
value1={};
value2={};
value3={};
InfoStruct = struct(field1,value1,field2,value2,field3,value3);
[finalX, finalY]=size(RoomInfoStruct);
for i=1:finalY
    for (j=1: finalY)
    in = inpolygon(RoomInfoStruct(i).wordCentY,RoomInfoStruct(i).wordCentX,roomCords{j,2},roomCords{j,1});
    if(in==1)
      %InfoStruct(i).room_name=RoomInfoStruct(j).roomName;
      RoomInfoStruct(i).room_CoordinateX=roomCords{j,2};
      RoomInfoStruct(i).room_CoordinateY=roomCords{j,1};
    end
    end
end
for i=1:finalY
    RoomInfoStruct(i).roomArea=polyarea( RoomInfoStruct(i).room_CoordinateX,RoomInfoStruct(i).room_CoordinateY)
end
%% Desription of rooms
text = 'In this architectural floor plan, there are';
numOfRooms=finalY;
if(finalY==1)
    text=[text,'one room'];
else
    text=strcat(text,',', num2str(numOfRooms),' rooms .');
end
%finalY=1;
temp_array=num2cell(zeros(finalY,1));
for i=1: finalY
temp_array{i,1}=RoomInfoStruct(i).roomName;
end
for i=1: finalY
 temp_array{i,1}=char(temp_array{i,1}); 
end
temp_counter=0;
space1=' ';
text=[text,space1,' There are ',];
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
for i=1: finalY
    
    temp_counter=cellfun(cellfind(temp_array{i,1}),celldata());
    occurence=sum(temp_counter);
    space1=' ';
    text=[text,num2str(occurence),space1,(char(RoomInfoStruct(i).roomName)),',' ]
    
end
text=strcat(text,'.');
%%
%extractin adjacency properties

[roomX1, roomY1]=size(room_locations_temp );
room_locations_temp = room_locations_temp(100:roomX1-100,100:roomY1-100);
adj12=adjacency_mat(room_locations_temp);
adj1=adjc(adj12);
[sizeX_adj, sizeY_adj]= size(adj1);
temp_adj=num2cell(zeros(sizeX_adj,sizeY_adj));
%temp_counter2=2;
roomIndices=num2cell(zeros(no_of_labels,1));
 for(i=1: finalY)
%     temp_array{i,2}=i+1;
[rowRI,colRI]=find(room_locations_temp==i+1);
roomIndices{i,1}=rowRI;
roomIndices{i,2}=colRI;
roomIndices{i,3}=round(mean(rowRI));
roomIndices{i,4}=round(mean(colRI));
 end
for i=1:finalY
    for (j=1: finalY)
    in = inpolygon(roomIndices{i,4},roomIndices{i,3},RoomInfoStruct(j).room_CoordinateX,RoomInfoStruct(j).room_CoordinateY);
    if(in==1)
      %InfoStruct(i).room_name=RoomInfoStruct(j).roomName;
      RoomInfoStruct(j).roomLabel=(room_locations_temp(roomIndices{i,3},roomIndices{i,4})-1);
      %RoomInfoStruct(i).room_CoordinateY=roomCords{j,1};
    end
    end
end
 

for (i=1: sizeX_adj)
    for(j=1: sizeY_adj)
        if(adj1(i,j)~=0)
            for(k=1:finalY)
                if(adj1(i,j)== RoomInfoStruct(k).roomLabel)
            temp_adj{i,j}=temp_array{k,1};
                end
            end
        end
    end
end
%% adjacency description
for(i=1: sizeX_adj)
    if(temp_adj{i}~=0)
        text=[text,space1,temp_adj{i},',',' is adjacent with ',space1,temp_adj{i,2},'.'];
    end
end
%%
%entry detection
for(i=1:finalY)
    if(strcmp(RoomInfoStruct(i).roomName,'ENTRY'))
        entry_label=RoomInfoStruct(i).roomLabel;
    end
end
%%
%path detection
adj_new=double(adj1);
grph_rooms=graph(adj_new(:,1),adj_new(:,2));
 order_rooms=dfsearch(grph_rooms,entry_label)
%path_rooms=minspantree(grph_rooms);
[T2,pred] = minspantree(grph_rooms,'Root',entry_label)
%directed_path = digraph(pred(pred~=0),find(pred~=0),[],grph_rooms.Nodes);
%plot(directed_path)
adj_mat=adjacency(T2)
directed_path1=sparse(adj_mat)
% order_rooms = graphtraverse(directed_path1,entry_label,'Method','DFS');
% order_rooms=order_rooms.';
% plot(T2)
degree_rooms=degree(T2);
%neighboring_rooms=neighbors(T2,entry_label);
%%
%data structure creation

c1=1;
field1='RoomName';
field2='RoomLabel';
field3='RoomSize';
field4='decors';
field5='UpperWall';
field6='LowerWall';
field7='RightWall';
field8='LeftWall';
field9='roomNeighbour';
value1={};
value2={};
value3={};
value4={};
value5={};
value6={};
value7={};
value8={};
value9={};
PathInfoStruct = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5,field6,value6,field7,value7,field8,value8,field9,value9);
for (i=1: finalY)
    
        for(k=1:finalY)
            if(i== RoomInfoStruct(k).roomLabel)
                PathInfoStruct(c1).RoomName=RoomInfoStruct(k).roomName;
                PathInfoStruct(c1).RoomLabel=RoomInfoStruct(k).roomLabel;
                c1=c1+1;
            end
        end
        
    
end
%%
%door based adjacency detection
[rectX1,~]=size(rect_cell1);
for(i=1:rectX1)
rect_new{i,1}=rect_cell1{i}(1)-10;
rect_new{i,2}=rect_cell1{i}(2)-10;
rect_new{i,3}=rect_cell1{i}(1)+rect_cell1{i}(3)+10;
rect_new{i,4}=rect_cell1{i}(2)+rect_cell1{i}(4)+10;
end
[rectX,~]=size(rect_new);
%c2=1;
c3=1;
for(i=1:finalY)
    for(j=1:rectX)
        in1 = inpolygon(rect_new{j,1},rect_new{j,2},RoomInfoStruct(i).room_CoordinateX,RoomInfoStruct(i).room_CoordinateY);
        if(in1==1)
            if(rect_new{j,3}> sizeY || rect_new{j,4}> sizeX)
                door_adjc{c3,2}=strcat(char(RoomInfoStruct(i).roomName),num2str(RoomInfoStruct(i).roomLabel));
                door_adjc{c3,1}='null';
                 door_adjc_new{c3,2}=RoomInfoStruct(i).roomName;
                 door_adjc_new{c3,1}='null';
                c3=c3+1;
            end
%             if(rect_new{j,1}<0 || rect_new{j,2}<0)
%                 door_adjc{c3,1}=RoomInfoStruct(i).roomName;
%                 door_adjc{c3,2}='null';
%             end
            
        end
        in2 = inpolygon(rect_new{j,3},rect_new{j,4},RoomInfoStruct(i).room_CoordinateX,RoomInfoStruct(i).room_CoordinateY);
        if(in2==1)
            if(rect_new{j,1}<0 || rect_new{j,2}<0)
                door_adjc{c3,2}=strcat(char(RoomInfoStruct(i).roomName),num2str(RoomInfoStruct(i).roomLabel));
                door_adjc{c3,1}='null';
                 door_adjc_new{c3,2}=RoomInfoStruct(i).roomName;
                 door_adjc_new{c3,1}='null';
                c3=c3+1;
            end
        end
        
    end
end
c2=c3;
for(i=1:finalY)
%i=5;
   for(j=1: rectX)
       if((rect_new{j,1}>0 && rect_new{j,1}<sizeY && rect_new{j,2}>0 && rect_new{j,2}<sizeX && rect_new{j,3}>0 && rect_new{j,3}<sizeY && rect_new{j,4}>0 && rect_new{j,4}<sizeX ))
       in1 = inpolygon(rect_new{j,1},rect_new{j,2},RoomInfoStruct(i).room_CoordinateX,RoomInfoStruct(i).room_CoordinateY);
       if(in1==1)
%            if(rect_new{j,3}> sizeY || rect_new{j,4}> sizeX)
%                door_adjc{c2,2}=RoomInfoStruct(i).roomName; 
%            
%           % aaa=RoomInfoStruct(i).roomName
%            else
%               
%           end
            door_adjc{c2,1}=strcat(char(RoomInfoStruct(i).roomName),num2str(RoomInfoStruct(i).roomLabel));
            door_adjc_new{c2,1}=RoomInfoStruct(i).roomName;
           for(k=1:finalY)
          % k=1;
               in2=inpolygon(rect_new{j,3},rect_new{j,4},RoomInfoStruct(k).room_CoordinateX,RoomInfoStruct(k).room_CoordinateY);
               if(in2==1)
                   %door_adjc{i,1}=RoomInfoStruct(i).roomName;
                   door_adjc{c2,2}=strcat(char(RoomInfoStruct(k).roomName),num2str(RoomInfoStruct(k).roomLabel));
                   door_adjc_new{c2,2}=RoomInfoStruct(k).roomName;
                   c2=c2+1;
               else
%                    door_adjc{i,1}=RoomInfoStruct(i).roomName;
                    %door_adjc{c2,2}='null';
               end
           end
%        else
%            door_adjc{i,1}=RoomInfoStruct(i).roomName;
       end
       end
   end
end

for(i=1:finalY)
   for(j=1: rectX)
       
       if((rect_new{j,1}>0 && rect_new{j,1}<sizeY && rect_new{j,2}>0 && rect_new{j,2}<sizeX && rect_new{j,3}>0 && rect_new{j,3}<sizeY && rect_new{j,4}>0 && rect_new{j,4}<sizeX ))
       in1 = inpolygon(rect_new{j,1},rect_new{j,2},RoomInfoStruct(i).room_CoordinateX,RoomInfoStruct(i).room_CoordinateY);
       if(in1==1)
           c6=1;
           % door_adjc{c2,1}=RoomInfoStruct(i).roomName;
           for(k=1:finalY)
          
               in2=inpolygon(rect_new{j,3},rect_new{j,4},RoomInfoStruct(k).room_CoordinateX,RoomInfoStruct(k).room_CoordinateY);
               if(in2==0)
                   missed_door(c6)=1;
                   c6=c6+1;
                missed_door
               end
           end
           if(sum(missed_door)==finalY)
               door_adjc{c2,2}=strcat(char(RoomInfoStruct(i).roomName),num2str(RoomInfoStruct(i).roomLabel));
               door_adjc{c2,1}='null';
                door_adjc_new{c2,2}=RoomInfoStruct(i).roomName;
                door_adjc_new{c2,1}='null';
           end
%        else
            clear missed_door
%            door_adjc{i,1}=RoomInfoStruct(i).roomName;
       end
       end
   end
end
[doorAdX,~]=size(door_adjc)
for(i=1:doorAdX)
    doorR1{i}=char(door_adjc{i,1});
end
[uniqueR1,~,idx1]=unique(doorR1);
%uniqueR1=char(uniqueR1);
countR1=accumarray(idx1(:),1,[],@sum);
countCellR1=num2cell(countR1);
tmp1=[uniqueR1;countCellR1'];
unique_countR1=struct(tmp1{:});
for(i=1:doorAdX)
    doorR2{i}=char(door_adjc{i,2});
end
[uniqueR2,~,idx2]=unique(doorR2);
%uniqueR2=char(uniqueR2);
countR2=accumarray(idx2(:),1,[],@sum);
countCellR2=num2cell(countR2);
tmp2=[uniqueR2;countCellR2'];
unique_countR2=struct(tmp2{:});
%%
%Area based size detection
for(i=1:finalY)
   if(RoomInfoStruct(i).roomArea< 450000)
       PathInfoStruct(RoomInfoStruct(i).roomLabel).RoomSize=' Small size '
   end
   if(RoomInfoStruct(i).roomArea> 450000 && RoomInfoStruct(i).roomArea< 750000 )
       PathInfoStruct(RoomInfoStruct(i).roomLabel).RoomSize=' Medium size '
   end
   if(RoomInfoStruct(i).roomArea>750000)
       PathInfoStruct(RoomInfoStruct(i).roomLabel).RoomSize=' Large size '
   end
   
end
%% decor information extraction
field1='decorX1';
field2='decorY1';
field3='decorX2';
field4='decorY2';
field5='decor_name'
value1={};
value2={};
value3={};
value4={};
value5={};
decorInfoStruct=struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5);
for(i=1:length(st1))
    decor_locn{i}=double(decor_locn{i});
end
for(i=1:length(st1))
    decor_loc_new{i,1}=decor_locn{i}(1);
    decor_loc_new{i,2}=decor_locn{i}(2);
    decor_loc_new{i,3}=decor_locn{i}(1)+decor_locn{i}(3);
    decor_loc_new{i,4}=decor_locn{i}(2)+decor_locn{i}(4);
end
decor_loc_new1{1,1}=decor_loc_new{1,1};
decor_loc_new1{1,2}=decor_loc_new{1,2};
decor_loc_new1{1,3}=decor_loc_new{1,3};
decor_loc_new1{1,4}=decor_loc_new{1,4};
decor_index1(1)=decor_index(1);
c10=1;
for(i=2:length(st1))
    
    if(decor_loc_new{i,1}== decor_loc_new{i-1,1} && decor_loc_new{i,2}== decor_loc_new{i-1,2} && decor_loc_new{i,3}== decor_loc_new{i-1,3} && decor_loc_new{i,4}== decor_loc_new{i-1,4} )
    
    else
       % decor_index1(c10)=decor_index(i-1);
        c10=c10+1;
        decor_loc_new1{c10,1}=decor_loc_new{i,1};
        decor_loc_new1{c10,2}=decor_loc_new{i,2};
        decor_loc_new1{c10,3}=decor_loc_new{i,3};
        decor_loc_new1{c10,4}=decor_loc_new{i,4};
        decor_index1(c10)=decor_index(i);
    end
end
% decor info structure
[decor_locX,~]=size(decor_loc_new1);
for(i=1:decor_locX)
    decorInfoStruct(i).decorX1=decor_loc_new1{i,1};
    decorInfoStruct(i).decorY1=decor_loc_new1{i,2};
    decorInfoStruct(i).decorX2=decor_loc_new1{i,3};
    decorInfoStruct(i).decorY2=decor_loc_new1{i,4};
    decorInfoStruct(i).decor_name=decorName.sign_object{decor_index1(i),2};
end
% decor mapping
%c4=1;
for(i=1: finalY)
    c4=1;
    for(j=1:decor_locX)
    in3=inpolygon(decor_loc_new1{j,1},decor_loc_new1{j,2},RoomInfoStruct(i).room_CoordinateX,RoomInfoStruct(i).room_CoordinateY);
    in4=inpolygon(decor_loc_new1{j,3},decor_loc_new1{j,4},RoomInfoStruct(i).room_CoordinateX,RoomInfoStruct(i).room_CoordinateY);
    if(in3==1 && in4==1)
        decor_temp{c4}=decorInfoStruct(j).decor_name;
        c4=c4+1;
       % PathInfoStruct(RoomInfoStruct(i).roomLabel).decors=decorInfoStruct(j).decor_name;
    end
    
    end
    PathInfoStruct(RoomInfoStruct(i).roomLabel).decors=decor_temp;
    clear decor_temp
end
%% wall information extraction
for(i=1: finalY)
    PathInfoStruct(i).UpperWall=wall_texture{i,2};
    PathInfoStruct(i).LowerWall=wall_texture{i,3};
    PathInfoStruct(i).RightWall=wall_texture{i,4};
    PathInfoStruct(i).LeftWall=wall_texture{i,5};
end
%% neighboring room information storage
for(i=1:doorAdX)
door_adjc_char{i,1}=char(door_adjc{i,1});
door_adjc_char{i,2}=char(door_adjc{i,2});
end
for(i=1:doorAdX)
door_adjc_char_new{i,1}=char(door_adjc_new{i,1});
door_adjc_char_new{i,2}=char(door_adjc_new{i,2});
end
for(i=1: finalY)
    c8=1;
    for(j=1: doorAdX)
        if(strcmp(door_adjc_char{j,1},strcat(char(PathInfoStruct(i).RoomName),num2str(PathInfoStruct(i).RoomLabel))))
            neighbour_temp{c8}=door_adjc_char_new{j,2};
            c8=c8+1;
            %PathInfoStruct(i).roomNeighbour=door_adjc_char_new{j,2};
        end
        if(strcmp(door_adjc_char{j,2},strcat(char(PathInfoStruct(i).RoomName),num2str(PathInfoStruct(i).RoomLabel))))
            neighbour_temp{c8}=door_adjc_char_new{j,1};
            c8=c8+1;
            %PathInfoStruct(i).roomNeighbour=door_adjc_char_new{j,1};
        end
        
    end
    PathInfoStruct(i).roomNeighbour=neighbour_temp;
    clear neighbour_temp
end
%% decor count
for(i=1: finalY)
    XX1=PathInfoStruct(i).decors;
    [uniqueXX1,~,J1]=unique(XX1)
    occ_dec=histc(J1,1:numel(uniqueXX1))
    decor_count{i,1}=uniqueXX1;
    decor_count{i,2}=occ_dec;
end

%%
%description generation
[orderX,~]=size(order_rooms);
text=strcat(text,'We are entering into the house via drawing room of the house.');
% neighboring_rooms_entry=neighbors(T2,entry_label);
% [no_ngbr_ent,~]=size(neighboring_rooms_entry);
% text=strcat(text,'It has',num2str(no_ngbr_ent),'neighboring rooms');
% for(i=1:no_ngbr_ent)
%     text=strcat(text, 'It has a door which opens to', char(PathInfoStruct(neighboring_rooms_entry(i)).RoomName));
% end

for(i=1:orderX)
%i=2;
    doorCount=0;
    doorCount1=0;
    doorCount2=0;
text=[text,' Now we enter into ',space1,char(PathInfoStruct(order_rooms(i)).RoomName)];
text=[text,' This is a ',char(PathInfoStruct(order_rooms(i)).RoomSize),space1,'room.'];
if(myIsField(unique_countR1,strcat(char(PathInfoStruct(order_rooms(i)).RoomName),num2str(PathInfoStruct(order_rooms(i)).RoomLabel)))==1)
doorCount1=eval(strcat('unique_countR1','.',char(PathInfoStruct(order_rooms(i)).RoomName),num2str(PathInfoStruct(order_rooms(i)).RoomLabel)));
doorCount=doorCount1;
end
if(myIsField(unique_countR2,strcat(char(PathInfoStruct(order_rooms(i)).RoomName),num2str(PathInfoStruct(order_rooms(i)).RoomLabel)))==1)
doorCount2=eval(strcat('unique_countR2','.',char(PathInfoStruct(order_rooms(i)).RoomName),num2str(PathInfoStruct(order_rooms(i)).RoomLabel)));
doorCount=doorCount+doorCount2;
end
%doorCount=doorCount1+doorCount2;
space1=' ';
text=[text,space1,'This room has']
total1=sum(count(decor_count{order_rooms(i),2}));
for(k2=1:total1)
text=[text,',',space1,num2str(decor_count{order_rooms(i),2}(k2)),char(decor_count{order_rooms(i),1}(k2)),'.']
end
text=[text,space1,'as decors.']
if(doorCount==1)
text=[text,' It has ',space1,num2str(doorCount),' door.']
else
text=[text,' It has ',space1,num2str(doorCount),' doors.']
end
for(k=1:doorAdX)
    if(strcmp(door_adjc_char{k,2},strcat(char(PathInfoStruct(order_rooms(i)).RoomName),num2str(PathInfoStruct(order_rooms(i)).RoomLabel))))
        if(strcmp(door_adjc_char{k,1},'null'))
            text=strcat(text,' It has a door opening to outside of the house. ')
        end
    end
    
end
c5=1;
current_door{c5,1}='null';
no_door_entry{1,1}='no_door'
for(k=1:doorAdX)
  if(strcmp(door_adjc_char{k,1},strcat(char(PathInfoStruct(order_rooms(i)).RoomName),num2str(PathInfoStruct(order_rooms(i)).RoomLabel))))
      current_door{c5,1}=door_adjc_char_new{k,1};
      current_door{c5,2}=door_adjc_char_new{k,2};
      no_door_entry{1,1}='door_found';
      
      %current_door
    c5=c5+1;
%   else
%       current_door{c5,1}='no_door_found';
      %current_door
  end
  
end
c7=1;
for(k=1:doorAdX)
    if(strcmp(door_adjc_char{k,1},'null'))
        current_door1{c7,1}='null';
        current_door1{c7,2}=door_adjc_char_new{k,2};
        c7=c7+1;
    end
end
if( strcmp(no_door_entry,'no_door'))
    text=strcat(text,' There is no door opening to other rooms  ');
    current_door{c5,1}='empty';
end
current_door
if(~strcmp(current_door,'null') )
    if(~strcmp(current_door,'empty'))
[size_temp,~]=size(current_door)
for(j=1:size_temp)
text=[text,' It has a door opening to ',space1,char(current_door{j,2}),'.']
end
    end
end
% if(strcmp(current_door1,'null'))
%     text=strcat(text,' It has a door opening to outside of house. ')
% end
% if(strcmp(current_door,'null'))
%      text=strcat(text,'It has a door opening to outside of house.')
% end
text=strcat(text,' Its front wall is a,',PathInfoStruct(order_rooms(i)).UpperWall,' wall.');
text=strcat(text,' Its backside wall is a, ',PathInfoStruct(order_rooms(i)).LowerWall,' wall.');
text=strcat(text,' Its right hand side wall is a, ',PathInfoStruct(order_rooms(i)).RightWall,' wall.');
text=strcat(text,' Its left hand side wall is a, ',PathInfoStruct(order_rooms(i)).LeftWall,' wall.');
if(doorCount==1)
 %neighRoom=neighbors(T2,order_rooms(i))  
 text=[text,' It is a dead end, we have to move back to',space1,char(PathInfoStruct(order_rooms(i)).roomNeighbour),'.'] 
end
clear current_door
clear current_door1
end
%% writng description in a file
fileID = fopen('description.txt','w');
fprintf(fileID,'%6s',text);
fclose(fileID);
toc;
