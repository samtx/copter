% Make 3D bar graphs for full factorial results

% times( 'Bat#' , 'Mot#', 'Prop#') = time

for i = 1:5
    figure;
    bar3(times(:,:,i))
    title(['Flight Time (Min) with Prop # ',num2str(i)]);
    xlabel('Battery #'); ylabel('Motor #');
end
