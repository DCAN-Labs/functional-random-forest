function tightplot(R,C, i, varargin)
%function tightplot(R,C, i, varargin)
%     BottomSpace = 0.1300;
%     TopSpace = 0.1;
%     LeftSpace=0.11;
%     RightSpace=0.11;
%     BetweenH=0;
%     BetweenV=0;

BottomSpace = 0.1300;
TopSpace = 0.1;
LeftSpace=0.11;
RightSpace=0.11;
BetweenH=0.;
BetweenV=0.03;

v = length(varargin);
q=1;
while q<=v;
    switch lower(varargin{q})
        case 'bottomspace'
            BottomSpace = varargin{q+1};
            q = q+1;
        case 'topspace'
            TopSpace = varargin{q+1};
            q = q+1;
        case 'leftspace'
            LeftSpace = varargin{q+1};
            q = q+1;
        case 'rightspace'
            RightSpace = varargin{q+1};
            q = q+1;
        case 'betweenh';
            BetweenH = varargin{q+1};
            q = q+1;
        case 'betweenv';
            BetweenV = varargin{q+1};
            q = q+1;
        case 'hight';
            hight = varargin{q+1};
            q = q+1;
            
        otherwise
            disp(['Unknown option ',varargin{q}])
    end;
    q = q+1;
end;
ii=zeros(2,1);
ii(:)=i;
i=ii;

if exist('hight')
else
    hight=1;
end

if C==1
    rsel = mod(ceil(i(1)/1),R);
else
    rsel = mod(ceil(i(1)/C-1),R);
end
csel = mod(i(1)-1,C);
H = (1 - TopSpace-BottomSpace - BetweenV*(R-1))/R;H;
if C==1
    W = (1 - LeftSpace-RightSpace - BetweenH)/C;W=W*(diff(i)+1);
else
    W = (1 - LeftSpace-RightSpace - BetweenH*(C-1))/C;W=W*(diff(i)+1);
end
B = BottomSpace + (R - rsel -1)*(H+BetweenV);
L = LeftSpace + csel*(W/(diff(i)+1)+BetweenH);

p = [L B W H*hight];
subplot('position', p);