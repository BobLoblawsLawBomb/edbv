function [indices, vx, vy, output_vmask, output_cmask] = tryToLinkComponents( oldPositions, newPositions, oldClasses, newClasses, ofCompMasks, ofCompPositions, of, mask_search_radius, position_search_radius, compIgnore)
%   Sucht aus einer liste von Positionen, unter Zuhilfenahme einer Liste von
%   Optical-Flow-Masken und einem OpticalFlow Vektor-Feld, die Position welche 
%   am wahrscheinlichsten die vorgänger Position von newPosition war.
%   Und gibt den index dieser Position im oldPositions Array zurück.
%
%   --- INPUT ---
%
%   oldPositions
%    Liste mit Vorgänger-Positionen. Enthält [x y] Einträge.
%
%   newPositions
%    Liste mit neuen Positionen, enthält [x y] Einträge, für die jeweils eine 
%    Vorgänger-Position gesucht werden soll.
%
%   oldClasses (Wird momentan nicht verwendet)
%    Zu jedem Positions-Eintrag in oldPositions eine zugehörige Farbklasse.
%    Indices müssen korrespondieren.
%
%   newClasss (Wird momentan nicht verwendet)
%    Zu jedem Positions-Eintrag in newPositions eine zugehörige Farbklasse.
%    Indices müssen korrespondieren.
%   
%   ofCompMasks
%    Liste mit Masken die Bereiche eingrenzen in denen Bewegungen
%    stattfinden.
%   
%   ofCompPositions
%    Liste mit den zugehörigen Positionen (Mittelpunkte) der
%    ofCompMasks. Indices müssen korrespondieren.
%
%   of
%    Das Optical-Flow Vektor-Feld.
%
%   mask_search_radius
%    Der Radius um die newPosition innerhalb dessen OpticalFlow Masken als
%    zugehörig zur Position betrachtet werden.
%
%   position_search_radius
%    Der Radius der den Suchbereich, in dem Vorgänger-Positionen aus
%    oldPositions als Kandidaten für Vorgänger der newPosition gewertet
%    werden, grundlegend beeinflusst.
%
%   compIgnore
%    Liste an indices von oldPosition die besagt, dass die oldPositions an
%    den entsprechenden indices nicht berücksichtigt werden sollen.
%   
%   --- OUTPUT ---
%
%   index
%    Der Index aus dem oldPositions Array, von dem behauptet wird, dass er
%    auf die Vorgänger-Position von newPosition verweist.
%    Falls index = 0, bedeutet dass, dass keine Position gefunden wurde,
%    was interpretiert werden kann, als neue Komponente zu der es noch keine 
%    oldPositions gibt.
%
%   vx
%    x-Komponente des gemittelten Geschwindigkeits-Vektor aus dem zugewiesenen 
%    Optical-Flow Bereich für newPosition.
%
%   vy
%    y-Komponente des gemittelten Geschwindigkeits-Vektor aus dem zugewiesenen 
%    Optical-Flow Bereich für newPosition.
%
%   output_vmask
%    Maske die den Suchbereich für zugehörige Optical-Flow-Masken beinhaltet.
%
%   output_smask
%    Maske die den Suchbereich für oldPositions beinhaltet.
%   
%
%   @author Andreas Mursch-Radlgruber
% ---------------------------------------------

%matrix um bereiche zu speichern in denen die geschwindigkeiten der
%komponenten gemittelt werden.
output_vmask = false(size(of));
output_cmask = false(size(of));

newPositionSize = size(newPositions);

indices = zeros(newPositionSize(1), 1);
vx = zeros(newPositionSize(1), 1);
vy = zeros(newPositionSize(1), 1);

%Versuche zu jeder Position im newPositions Array einen vorgänger in
%oldPositions zu finden.
for i = 1 : newPositionSize(1)
    
    newCompPosition = newPositions(i,:);
    newCompClass = newClasses(i);
    
    %Suche passende Vorgänger-Position
    [oldCompIndex, nvx, nvy, vmask, smask] = findOldPosition( oldPositions, newCompPosition, oldClasses, newCompClass, ofCompMasks, ofCompPositions, of, mask_search_radius, position_search_radius, compIgnore);
    
    vx(i) = nvx;
    vy(i) = nvy;
    
    %Falls eine Vorgänger-Position gefunden wurde
    if(oldCompIndex ~= 0)
        
        indices(i) = oldCompIndex;
        
        %TODO: if the position is already taken, choose which one is more
        %relevant from the perspective of the old position
        %the one who lost can try again, adding the lost position to a
        %temporary ignore-list.
        
        %draw oldPosition-search-areas
        output_vmask = or(output_vmask, vmask);
        
        %draw component-masks
        output_cmask = or(output_cmask, smask);
        
    else
        indices(i) = oldCompIndex;
    end
    
end

end