function [ exactpdf ] = exact_full_PDF(cc, evdPar)
% 10/10/16 exact PDF for i.i.d. data
%     C1 = 1./sqrt(pi) *gamma((evdPar(1)-1)/2)/gamma((evdPar(1)-2)/2);
%     sum = C1*(cc.*hypergeom([1/2,-(evdPar(1)-4)/2 ],3/2,cc.^2))+1/2;
%     %figure, plot(sum)
%     exactpdf = evdPar(2)*sum.^(evdPar(2)-1).*C1.* ((1-cc.^2).^((evdPar(1)-4)/2));

    exactpdf = evdPar(2)*(1/2*(1+betainc(cc.^2,1/2, evdPar(1)/2-1))).^(evdPar(2)-1).*(1-cc.^2).^((evdPar(1)-4)/2)./beta(1/2,  evdPar(1)/2-1);
end

