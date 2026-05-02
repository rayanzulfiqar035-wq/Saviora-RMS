let cart = [];
let currentModifications = {}; // { recipe_id: { removed_id: X, added_id: Y, extra_cost: Z } }
let currentItemPrice = 0;
let baseItemPrice = 0;

// Initialize Modal
let modifierModal;
document.addEventListener('DOMContentLoaded', () => {
    modifierModal = new bootstrap.Modal(document.getElementById('modifierModal'));
});

function openModifierModal(itemId, itemName, itemPrice) {
    document.getElementById('modItemId').value = itemId;
    document.getElementById('modItemName').value = itemName;
    document.getElementById('modItemPrice').value = itemPrice;
    
    document.getElementById('modifierModalTitle').innerText = itemName;
    document.getElementById('modQty').innerText = '1';
    
    baseItemPrice = parseFloat(itemPrice);
    currentItemPrice = baseItemPrice;
    currentModifications = {};
    updateModalPrice();
    
    // Fetch Ingredients via AJAX
    fetch(`/orders/api/menu/${itemId}/ingredients`)
        .then(response => response.json())
        .then(data => {
            const list = document.getElementById('ingredientsList');
            list.innerHTML = '';
            
            if(data.length === 0) {
                list.innerHTML = '<div class="text-muted small">No modifications available for this item.</div>';
                return;
            }
            
            data.forEach(ing => {
                let html = `<div class="d-flex justify-content-between align-items-center mb-2 p-2" style="background: rgba(255,255,255,0.05); border-radius: 8px;">
                    <div>${ing.name}</div>`;
                
                if(ing.substitutes.length > 0) {
                    // Use recipe_id as the key; pass removed_id, added_id, and extra_cost from DB
                    html += `<select class="form-select form-select-sm bg-dark text-white border-secondary" style="width: auto;" 
                                onchange="handleSubstitution(${ing.recipe_id}, ${ing.ingredient_id}, this.value, this.options[this.selectedIndex].dataset.extraCost)">
                                <option value="">Keep Original</option>`;
                    ing.substitutes.forEach(sub => {
                        const costLabel = sub.extra_cost > 0 ? `+Rs.${sub.extra_cost}` : 'Free';
                        html += `<option value="${sub.id}" data-extra-cost="${sub.extra_cost}">Swap → ${sub.name} (${costLabel})</option>`;
                    });
                    html += `</select>`;
                } else {
                    html += `<small class="text-muted">No swaps available</small>`;
                }
                
                html += `</div>`;
                list.innerHTML += html;
            });
        });
        
    modifierModal.show();
}

function updateQty(change) {
    let el = document.getElementById('modQty');
    let qty = parseInt(el.innerText) + change;
    if(qty >= 1 && qty <= 20) {
        el.innerText = qty;
        updateModalPrice();
    }
}

// recipeId = unique key per ingredient slot
// originalId = ingredient being removed
// newId = replacement ingredient id (empty string = revert to original)
// extraCost = the authoritative cost from MENU_INGREDIENT_SUBSTITUTION (string from dataset)
function handleSubstitution(recipeId, originalId, newId, extraCost) {
    if(!newId) {
        delete currentModifications[recipeId];
    } else {
        currentModifications[recipeId] = {
            removed_id:          originalId,
            added_id:            parseInt(newId),
            extra_cost_per_unit: parseFloat(extraCost) || 0
        };
    }
    updateModalPrice();
}

function updateModalPrice() {
    let modsCost = 0;
    Object.values(currentModifications).forEach(mod => {
        modsCost += mod.extra_cost_per_unit;
    });
    
    let qty = parseInt(document.getElementById('modQty').innerText);
    currentItemPrice = (baseItemPrice + modsCost) * qty;
    document.getElementById('modTotalPrice').innerText = `PKR ${currentItemPrice.toFixed(2)}`;
}

function addToCart() {
    let itemId = document.getElementById('modItemId').value;
    let itemName = document.getElementById('modItemName').value;
    let qty = parseInt(document.getElementById('modQty').innerText);
    
    let mods = Object.values(currentModifications);
    
    cart.push({
        menu_item_id: parseInt(itemId),
        name: itemName,
        quantity: qty,
        unit_price: baseItemPrice,
        modifications: mods,
        total_price: currentItemPrice
    });
    
    modifierModal.hide();
    renderCart();
}

function renderCart() {
    const container = document.getElementById('cartItems');
    
    if(cart.length === 0) {
        container.innerHTML = `
            <div class="text-center text-muted py-5">
                <i class="bi bi-cart-x fs-1 mb-2 d-block"></i>
                Cart is empty
            </div>`;
        document.getElementById('cartSubtotal').innerText = 'PKR 0.00';
        return;
    }
    
    container.innerHTML = '';
    
    let subtotal = 0;
    
    cart.forEach((item, index) => {
        subtotal += item.total_price;
        
        let modHtml = '';
        if(item.modifications.length > 0) {
            modHtml = `<div class="small text-warning mt-1"><i class="bi bi-info-circle"></i> Modified (${item.modifications.length} changes)</div>`;
        }
        
        container.innerHTML += `
            <div class="cart-item position-relative">
                <button class="btn btn-sm btn-link text-danger position-absolute top-0 end-0 p-2" onclick="removeFromCart(${index})"><i class="bi bi-x-circle-fill fs-5"></i></button>
                <div class="fw-bold mb-1">${item.name}</div>
                <div class="d-flex justify-content-between align-items-center text-muted small">
                    <div>Qty: ${item.quantity} x PKR ${item.unit_price}</div>
                    <div class="fw-bold text-white fs-6">PKR ${item.total_price.toFixed(2)}</div>
                </div>
                ${modHtml}
            </div>
        `;
    });
    
    document.getElementById('cartSubtotal').innerText = `PKR ${subtotal.toFixed(2)}`;
}

function removeFromCart(index) {
    cart.splice(index, 1);
    renderCart();
}

function submitOrder(tableId) {
    if(cart.length === 0) {
        alert("Cart is empty!");
        return;
    }
    
    // AJAX POST Request
    fetch('/orders/api/place_order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            table_id: tableId,
            cart: cart
        })
    })
    .then(response => response.json())
    .then(data => {
        if(data.status === 'success') {
            cart = [];
            renderCart();
            // Redirect to checkout since they hit send to kitchen for simplicity in this demo,
            // or just flash success. The instructions state billing handles checkout.
            // Let's redirect to table map or show a success message.
            window.location.href = `/orders/table_map`;
        } else {
            alert("Error: " + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert("An error occurred placing the order.");
    });
}
