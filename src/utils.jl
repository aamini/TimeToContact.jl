export runTTC, ttc, solve_ttc, readImage, uniformBlur, rgb2gray


function readImage(f)
    img1 = restrict(read(f,Image))
end
function rgb2gray(img)
    img = convert(Array{Float64,3}, separate(img))
    (mean(img,3)[:,:,1])
end
function uniformBlur(img, n)
    I = convn(img, ones(n,n)./(n^2))
    I[n:size(I,1)-n+1,n:size(I,2)-n+1]
end

function krestrict(k,img)
    for i=k:-1:1
        img=restrict(img);
    end
    img
end


function ttc(img1,img2)
    
    (T_n,x0_n,y0_n,EX_n,EY_n,ET_n,v_n)=solve_ttc(img1,img2)
    (T_p,x0_p,y0_p,EX_p,EY_p,ET_p,v_p) = (T_n,x0_n,y0_n,EX_n,EY_n,ET_n,v_n)

    T_p = T_n+1

    k=0
    while T_p > T_n && T_n>0 
        (T_p,x0_p,y0_p,EX_p,EY_p,ET_p,v_p) = (T_n,x0_n,y0_n,EX_n,EY_n,ET_n,v_n)

        img1_ = restrict(uniformBlur(img1,2));
        img2_ = restrict(uniformBlur(img2,2));
        
        if minimum(size(img1_))<=6
            break
        end
        
        (T_n,x0_n,y0_n,EX_n,EY_n,ET_n,v_n)=solve_ttc(img1_,img2_)
        
        img1=img1_; img2=img2_
        k+=1
    end
    #println(k)
    return T_p, x0_p*k, y0_p*k, EX_p, EY_p, ET_p, v_p*k, k

end


function solve_ttc( img1, img2 )
    #SOLVE_TTC Computes the time to contact and focus of expansion 
    # using two images as input
    ## Inputs: 
    #   img1 = mxn matrix double image
    #   img2 = mxn matrix doulbe image (after img1)
    ## Outputs: 
    #   out  = 1x3 vector with the following components: 
    #          - T  = time to contact
    #          - x0 = x coordinate of FOE
    #          - y0 = y coordinate of FOE

    ## #####################################

    stack = cat(3,img1,img2);
    (m,n) = size(img1);

    ########################################
    ####  DEFINE Kernel Scaling Factors ####
    DIVIDE_EX = 16/(n); ####################
    DIVIDE_EY = 16/(m); ####################
    DIVIDE_ET = 4/(min(n,m)); ##############
    DIVIDE_GG = 1; #########################
    ########################################

    # ######################################

    ## setup

    xv = linspace(-n/2,n/2,n-4); yv=linspace(-m/2,m/2,m-4);
    x = [j for i in yv, j in xv];
    y = [i for i in yv, j in xv];
    
    ## create kernels that average both images
    sobel = [1;2;1]*[-1 0 1]; #sobel operator is 3x3
    sobel3_x = (1/DIVIDE_EX) * repeat(sobel,outer=[1,1,2]); 
    sobel3_y = (1/DIVIDE_EY) * repeat(sobel',outer=[1,1,2]); 
    prewitt2_t = (1/DIVIDE_ET) * reshape([1;1]*[-1 -1 1 1],2,2,2); #prewitt operator is 2x2

    EX = convn(stack,sobel3_x); #x dir grad
    EY = convn(stack,sobel3_y); #y dir grad
    ET = convn(stack,prewitt2_t); #t dir grad

    EX = EX[3:m-2,3:n-2,2];
    EY = EY[3:m-2,3:n-2,2];
    ET = ET[3:m-2,3:n-2,2];
    GG = EX.*x./(DIVIDE_GG) + EY.*y./(DIVIDE_GG); #radial grad

    ## solve
    E = [EX[:] EY[:] GG[:]];
    v = E\(-ET[:]); #v=3x1 vector 

    ## compile results
    x0 = -v[1]/v[3]; #foe x
    y0 = -v[2]/v[3]; #foe y
    T = 1/v[3];      #ttc
    return T,x0,y0,EX,EY,ET,v; #all results

end

runTTC(f) = runTTC(f, "search");

function runTTC(f, method)
    #f = VideoIO.openvideo("./test_vids/Newman4.avi")
    #f = VideoIO.openvideo("./test_vids/Tipper3.avi")
    #f = VideoIO.openvideo("./test_vids/ttc_car_clip.mp4")
    #f = VideoIO.openvideo("./test_vids/toyota.mp4")

    img1_rgb = readImage(f)
    img1 = rgb2gray(img1_rgb)
    
    if method=="search"
        img1 = uniformBlur(img1,5);
    elseif isa(method,Int)
        img1 = uniformBlur(img1,method)
    end
    
    (T,x0,y0,EX,EY,ET,v)=solve_ttc(img1,img1)


    (m,n) = size(img1)

    c = canvasgrid(2,2)
    ops = [:pixelspacing => [1,1]]

    (canvas,cEX,cEY,cET) = (c[1,1],c[1,2],c[2,2],c[2,1])

    canvas, ptnr = ImageView.view(canvas, img1_rgb; ops...)
    cEX, ptnrX = ImageView.view(cEX, EX;ops...)
    cEY, ptnrY = ImageView.view(cEY, EY;ops...)
    cET, ptnrT = ImageView.view(cET, ET;ops...)

    FOE = ImageView.annotate!(canvas, ptnr, ImageView.AnnotationText(0,0, "X"))
    TTC = ImageView.annotate!(canvas, ptnr, ImageView.AnnotationText(0,0, "X"))

    A = ImageView.annotate!(canvas, ptnr, ImageView.AnnotationText(0,0, "A"))
    B = ImageView.annotate!(canvas, ptnr, ImageView.AnnotationText(0,0, "B"))
    C = ImageView.annotate!(canvas, ptnr, ImageView.AnnotationText(0,0, "C"))

    ImageView.annotate!(cEX, ptnrX, ImageView.AnnotationText(n/2,30, "EX", color=RGB(1,0,0), fontsize=35))
    ImageView.annotate!(cEY, ptnrY, ImageView.AnnotationText(n/2,30, "EY", color=RGB(1,0,0), fontsize=35))
    ImageView.annotate!(cET, ptnrT, ImageView.AnnotationText(n/2,30, "ET", color=RGB(1,0,0), fontsize=35))


    records = Matrix(0,4);
    iter = 0;
    while !eof(f)
        try
            #read and view new image
            img2_rgb = readImage(f)
            img2 = rgb2gray(img2_rgb)

            if method=="search"
                img2 = uniformBlur(img2,5);
                #solve the least squares time to contact
                (T,x0,y0,EX,EY,ET,v,k)=ttc(img1,img2)
            elseif method=="none"
                (T,x0,y0,EX,EY,ET,v)=solve_ttc(img1,img2)
            elseif isa(method,Int)
                img2 = uniformBlur(img2,method)
                (T,x0,y0,EX,EY,ET,v)=solve_ttc(img1,img2)
            end
                    

                
            

            iter += 1

            if T>10^5 || T<0
                continue
            end
            
            records = [records; [iter T x0 y0]];

            _, ptnr = ImageView.view(canvas, img2_rgb;ops...)
            _, ptnrX = ImageView.view(cEX, EX;ops...)
            _, ptnrY = ImageView.view(cEY, EY;ops...)
            _, ptnrT = ImageView.view(cET, ET;ops...)

            #remove old annotations
            ImageView.delete!(canvas, FOE)
            ImageView.delete!(canvas, TTC)
            ImageView.delete!(canvas, A)
            ImageView.delete!(canvas, B)
            ImageView.delete!(canvas, C)

            #add new ones
            FOE = ImageView.annotate!(canvas, ptnr, ImageView.AnnotationText(x0+(n)/2, y0+(m)/2, "X", color=RGB(0,1,0), fontsize=20))
            TTC = ImageView.annotate!(canvas, ptnr, ImageView.AnnotationText(n/2,30, string(round(T*10)/10), color=RGB(0,0.5,0.5), fontsize=35))
            A = ImageView.annotate!(canvas, ptnr, ImageView.AnnotationText(n-60,m-60, string("A:    ",round(v[1]*100)/100), color=RGB(0,0.5,0.5), fontsize=15))
            B = ImageView.annotate!(canvas, ptnr, ImageView.AnnotationText(n-60,m-40, string("B:    ",round(v[2]*100)/100), color=RGB(0,0.5,0.5), fontsize=15))
            C = ImageView.annotate!(canvas, ptnr, ImageView.AnnotationText(n-60,m-20, string("C: ",round(v[3]*10000)/10000), color=RGB(0,0.5,0.5), fontsize=15))

            #increment moving image window
            img1_rgb = img2_rgb;
            img1 = img2;

            #sleep to slow down
            #sleep(0)

        catch e
            if isa(e, InterruptException) || (isa(e,ErrorException) && e.msg=="invalid window")
                return  records
            else
                throw(e)
            end
        end
    end
    return records
end

