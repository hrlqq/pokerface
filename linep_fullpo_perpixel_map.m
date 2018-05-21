t0=cputime;
path = '32.jpg';
img=imread(path);
img_gray=rgb2gray(img);
%img_gray =im2double(img_gray);
%img_gray = imresize(img_gray,[16 16]); %图片大于32 32 的话速度太慢
[H,W]=size(img_gray);
% color=0;
% for i=1:jump:H
%     for j=1:jump:W
%         
%         img_gray(i,j)=color;
%         color=color+1;
% 
%     end
% end

img_poker=img_gray;
x=[];                   
y=[];                   
mp = containers.Map({-1},{-1});                                                                                                                                                                                                                                                                                                                                                          ;                  
e=3;                    

copy = zeros(H,W);
img_min=255;
img_max=0;
jump = 1;
for i=1:jump:H
    for j=1:jump:W
        

        midi = 1;
        starti = i
        startj = j
        midpix = img_gray(i,j);
        if mp.isKey(midpix)
            img_poker(starti, startj) = mp(midpix);
            continue;
        end
        midindex = (i-1)*W+j;

        A=0*ones(1,H*W);
        Aeq=0*ones(1,H*W);
        Beq=[];
        b=[];

        toindex = 1;
        eqindex = 1;
        for k=1:H
            for l=1:W
                if k==starti && l==startj
                    continue;
                end
                cmppix = img_gray(k,l);
                cmpindex = (k-1)*W+l;
%                 if k == 97 && l==1
%                     sss = k
%                     ss = l
%                 end
                if midpix>cmppix
                    A(toindex,midindex)=-1;
                    A(toindex,cmpindex)=1;
                    b(toindex,1)=-1;
                    %b(toindex,1)=cmppix-midpix;
                elseif midpix<cmppix
                    A(toindex,midindex)=1;
                    A(toindex,cmpindex)=-1;
                    b(toindex,1)=-1;
                    %b(toindex,1)=midpix-cmppix;
                else

                    Aeq(eqindex,midindex)=1;
                    Aeq(eqindex,cmpindex)=-1;
                    Beq(eqindex,1)=0;
                    eqindex = eqindex+1;
      
                end
                toindex=toindex+1;
            end
        end

       
        eb=e*b;
        ti = H*W;
        lb=(0)*ones(ti,1);
        ub=(255)*ones(ti,1);

        if length(Beq) == 0
            Aeq=[];
        end
        if length(eb) == 0
            A = [];
        elseif length(eb) ~= length(A)

        end

        y=linprog([],A,eb,Aeq,Beq,lb,ub); % A 10751*12528 eb 10751*1 Aeq 308*12498 Beq 308*1 lb ub 10752*1
        img_poker(starti, startj) = y(midindex);
        mp(midpix) = y(midindex);

    end
end


figure(1)
subplot(2,2,1),imshow(img_gray),title('处理前');
subplot(2,2,2),imshow(img_poker),title('处理后');
subplot(2,2,3),imhist(img_gray),title('处理前直方图');
subplot(2,2,4),imhist(img_poker),title('处理后直方图');

imwrite(img_gray,'./before.jpg');
imwrite(img_poker,'./after.jpg');

%查看像素
% fid = fopen('before.txt','w');
% for i=1:H
%     for j=1:W
%         fprintf(fid,'%d\t',img_gray(i,j,1));
%     end
%     fprintf(fid,'\n');  
% end
% fclose(fid);
% 
% fid = fopen('after.txt','w');
% for i=1:H
%     for j=1:W
%         fprintf(fid,'%d\t',img_poker(i,j,1));
%     end
%     fprintf(fid,'\n');  
% end
% fclose(fid);
t1=cputime-t0;